import boto3
import json
from datetime import datetime, timedelta
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

# Create a CloudWatch Logs client
client = boto3.client('logs')
ec2_client = boto3.client('ec2')


slack_webhook_url = 'https://hooks.slack.com/services/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'

vpc_id = 'vpc-0c35249dde8617f14'
region_name = 'us-east-1'

def lambda_handler(event, context):
    # Defining the CloudWatch Logs Insights queries 
    log_group_name = f'prod-vpcflow-logs-{region_name}'

    # Time range for the queries (last 7 hours)
    start_time = int((datetime.utcnow() - timedelta(hours=7)).timestamp() * 1000)
    end_time = int(datetime.utcnow().timestamp() * 1000)

    # Define queries, including Port Scan Detection
    queries = {
        'Rejected Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol, dstPort
        | filter action = "REJECT"
        | stats count() as rejection_count by srcAddr, dstAddr, dstPort
        | sort rejection_count desc
        | filter rejection_count >= 10
        | limit 10000
        ''',
        'Accepted SSH Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol, dstPort
        | filter action = "ACCEPT" and dstPort = 22
        | stats count() as ssh_count by srcAddr, dstAddr
        | sort ssh_count desc
        | limit 10000
        ''',
        'Spoofed IP Addresses': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol
        | filter srcAddr in ["0.0.0.0", "255.255.255.255"]
        | stats count() as spoofed_count by srcAddr, dstAddr
        | sort spoofed_count desc
        | limit 10000
        ''',
        'Large Data Transfers': '''
        fields @timestamp, srcAddr, dstAddr, bytes
        | filter bytes > 1000000
        | stats sum(bytes) as total_bytes by srcAddr, dstAddr
        | sort total_bytes desc
        | limit 1
        ''',
        'High Packet Count': '''
        fields @timestamp, srcAddr, dstAddr, packets
        | filter packets > 5000
        | stats sum(packets) as total_packets by srcAddr, dstAddr
        | sort total_packets desc
        | limit 10000
        ''',
        'Port Scan Detection': '''
        fields @timestamp, srcAddr, dstPort, action, protocol
        | filter action = "REJECT"
        | stats count_distinct(dstPort) as port_count, count() as rejection_count by srcAddr
        | filter port_count > 30  # Only show IPs that tried more than 10 distinct ports
        | sort rejection_count desc
        | limit 10000
        '''
    }

    # Helper function to execute CloudWatch Insights query
    def execute_query(query):
        response = client.start_query(
            logGroupName=log_group_name,
            startTime=start_time,
            endTime=end_time,
            queryString=query,
        )
        query_id = response['queryId']
        while True:
            result = client.get_query_results(queryId=query_id)
            if result['status'] == 'Complete':
                return result

    # Get instance details (instance ID, name, region, account number)
    def get_instance_details():
        instance_id = ec2_client.describe_instances()['Reservations'][0]['Instances'][0]['InstanceId']
        instance_name = next(tag['Value'] for tag in ec2_client.describe_instances()['Reservations'][0]['Instances'][0]['Tags'] if tag['Key'] == 'Name')
        region = boto3.session.Session().region_name
        account_id = boto3.client('sts').get_caller_identity()['Account']
        return instance_id, instance_name, region, account_id

    # Safely extract a value from a query result or return a default
    def safe_extract(row, field_name, default="N/A"):
        return next((item['value'] for item in row if item['field'] == field_name), default)

    # Format Slack message attachments with colors and add contextual details
    def format_slack_message(query_label, results, color, no_data_message="No data found.", show_instance_details=False):
        # Handle no data condition
        if not results['results']:
            formatted_results = no_data_message
        else:
            # For Rejected Connections, include Source IP, Destination IP, Port, and Rejection Count
            if query_label == 'Rejected Connections':
                formatted_results = f"{'Source IP':<18} {'Dest IP':<18} {'Port':<6} {'Count':<5}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    dst_addr = safe_extract(row, 'dstAddr')
                    dst_port = safe_extract(row, 'dstPort')
                    count = safe_extract(row, 'rejection_count')
                    formatted_results += f"{src_addr:<18} {dst_addr:<18} {dst_port:<6} {count:<5}\n"
            # For Port Scan Detection, include Source IP, Distinct Ports, and Rejection Count
            elif query_label == 'Port Scan Detection':
                formatted_results = f"{'Source IP':<18} {'Port Count':<10} {'Rejections':<10}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    port_count = safe_extract(row, 'port_count')
                    rejection_count = safe_extract(row, 'rejection_count')
                    formatted_results += f"{src_addr:<18} {port_count:<10} {rejection_count:<10}\n"
            # For Accepted SSH Connections, include Source IP, Destination IP, and SSH Count
            elif query_label == 'Accepted SSH Connections':
                formatted_results = f"{'Source IP':<18} {'Dest IP':<18} {'Count':<5}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    dst_addr = safe_extract(row, 'dstAddr')
                    count = safe_extract(row, 'ssh_count')
                    formatted_results += f"{src_addr:<18} {dst_addr:<18} {count:<5}\n"
            # For Spoofed IP Addresses
            elif query_label == 'Spoofed IP Addresses':
                formatted_results = f"{'Source IP':<18} {'Dest IP':<18} {'Count':<5}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    dst_addr = safe_extract(row, 'dstAddr')
                    count = safe_extract(row, 'spoofed_count')
                    formatted_results += f"{src_addr:<18} {dst_addr:<18} {count:<5}\n"
            # For Large Data Transfers, include Source IP, Destination IP, and Total Bytes
            elif query_label == 'Large Data Transfers':
                formatted_results = f"{'Source IP':<18} {'Dest IP':<18} {'Total Bytes':<12}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    dst_addr = safe_extract(row, 'dstAddr')
                    total_bytes = safe_extract(row, 'total_bytes')
                    formatted_results += f"{src_addr:<18} {dst_addr:<18} {total_bytes:<12}\n"
            # For High Packet Count, include Source IP, Destination IP, and Total Packets
            elif query_label == 'High Packet Count':
                # Updated this section to include total_packets
                formatted_results = f"{'Source IP':<18} {'Dest IP':<18} {'Total Packets':<12}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    dst_addr = safe_extract(row, 'dstAddr')
                    total_packets = safe_extract(row, 'total_packets')  # Ensure total_packets is extracted
                    formatted_results += f"{src_addr:<18} {dst_addr:<18} {total_packets:<12}\n"
            else:
                formatted_results = f"{'Source IP':<20} {'Count':<5}\n" + "-" * 20 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    count = safe_extract(row, 'count')
                    formatted_results += f"{src_addr:<20} {count:<5}\n"

        # Include instance details only for Accepted SSH Connections
        if show_instance_details:
            instance_id, instance_name, region, account_id = get_instance_details()
            footer_text = f"Instance ID: {instance_id}, Name: {instance_name}, Region: {region}, Account: {account_id}"
        else:
            footer_text = ""

        attachment = {
            "color": color,
            "title": f"{query_label}",
            "text": f"```{formatted_results}```\n",  # Code block formatting
            "footer": footer_text,
            "ts": int(datetime.now().timestamp())
        }
        return attachment

    # Build the report header for the VPC Flow Logs Monitoring
    def build_report_header():
        account_id = boto3.client('sts').get_caller_identity()['Account']
        report_header = {
            "color": "#0000FF",  # Blue for report header
            "title": "Monitoring Report: VPC Flow Logs",
            "text": f"VPC ID: {vpc_id}\nAccount: {account_id}\nRegion: {region_name}",
            "ts": int(datetime.now().timestamp())
        }
        return report_header

    # Execute queries and format Slack messages with colors
    attachments = [build_report_header()]  # Start with the report header
    for query_label, query in queries.items():
        results = execute_query(query)

        # Set default for show_instance_details
        show_instance_details = False
        
        # Add specific no data messages for each query type
        if query_label == 'High Packet Count':
            no_data_message = "No high packet counts found in the last 7 hours."
        elif query_label == 'Large Data Transfers':
            no_data_message = "No large data transfers found in the last 7 hours."
        elif query_label == 'Rejected Connections':
            no_data_message = "No data found for 5+ rejected connections in the last 7 hours."
        elif query_label == 'Port Scan Detection':
            no_data_message = "No port scan activity detected in the last 7 hours."
        elif query_label == 'Accepted SSH Connections':
            no_data_message = "No accepted SSH connections found in the last 7 hours."
        elif query_label == 'Spoofed IP Addresses':
            no_data_message = "No spoofed IP addresses found in the last 7 hours."
        else:
            no_data_message = "No data found."

        if query_label == 'Rejected Connections':
            color = "#FF0000"  # Red for high rejected connections
        elif query_label == 'Accepted SSH Connections':
            color = "#FFFF00"  # Yellow for accepted SSH connections
            show_instance_details = True  # Show instance details only for SSH
        elif query_label == 'Port Scan Detection':
            color = "#FF4500"  # Orange for port scan detection
        elif query_label == 'Spoofed IP Addresses':
            color = "#FF6347"  # A different color for spoofed IPs
        elif query_label == 'Large Data Transfers':
            color = "#36a64f"  # Green for large data transfers
        elif query_label == 'High Packet Count':
            color = "#36a64f"  # Green for high packet count
        else:
            color = "#36a64f"  # Green for other queries

        # Format the message and add it to the attachments
        attachments.append(format_slack_message(query_label, results, color, no_data_message, show_instance_details))

    # Send message to Slack
    slack_payload = {
        "attachments": attachments,
        "channel": "#system-alerts"  # Change this to your Slack channel
    }
    
    req = Request(slack_webhook_url, data=json.dumps(slack_payload).encode('utf-8'), headers={'Content-Type': 'application/json'})

    try:
        response = urlopen(req)
        print("Message posted to Slack")
    except HTTPError as e:
        print(f"Request failed: {e.code} {e.reason}")
    except URLError as e:
        print(f"Server connection failed: {e.reason}")

    return {
        'statusCode': 200,
        'body': json.dumps('All queries executed and results sent to Slack.')
    }
