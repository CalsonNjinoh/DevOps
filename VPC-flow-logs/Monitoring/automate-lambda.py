import boto3
import json
from datetime import datetime, timedelta

# Create a CloudWatch Logs client
client = boto3.client('logs')

def lambda_handler(event, context):
    # Define the CloudWatch Logs Insights query
    log_group_name = 'vpcflowlogs'  # Change to your Log Group name
    query_string = '''
    fields @timestamp, srcAddr, dstAddr, action, protocol, dstPort
    | filter action = "REJECT"
    | stats count() as rejection_count by srcAddr
    | sort rejection_count desc
    | filter rejection_count >= 5
    | limit 10
    '''

    # Define the time range (last 5 minutes)
    start_time = int((datetime.utcnow() - timedelta(minutes=5)).timestamp() * 1000)
    end_time = int(datetime.utcnow().timestamp() * 1000)

    # Start the query
    response = client.start_query(
        logGroupName=log_group_name,
        startTime=start_time,
        endTime=end_time,
        queryString=query_string,
    )

    # Retrieve the query ID
    query_id = response['queryId']

    # Wait for the query to finish
    while True:
        result = client.get_query_results(queryId=query_id)
        if result['status'] == 'Complete':
            break

    # Process results to extract only IPs with their rejection counts
    ip_summary = []
    for row in result['results']:
        src_addr = next(item['value'] for item in row if item['field'] == 'srcAddr')
        rejection_count = next(item['value'] for item in row if item['field'] == 'rejection_count')
        ip_summary.append(f"{src_addr:<20} | {rejection_count}")

    # Create a table header
    table_header = "Source IP Address       | Rejection Count\n"
    table_header += "-" * 35

    # Combine header and results
    if ip_summary:
        message = table_header + "\n" + "\n".join(ip_summary)
    else:
        message = "No IP addresses with 5 or more rejections detected in the last 5 minutes."

    # Send the message through SNS
    sns_client = boto3.client('sns')
    sns_client.publish(
        TopicArn='arn:aws:sns:ca-central-1:891377304437:mydemo-topic',  # Replace with your SNS topic ARN
        Message=message,
        Subject='Alert: IPs with Multiple Rejected Connections'
    )

    return result




#test event code :

{
  "version": "0",
  "id": "12345678-1234-1234-1234-123456789012",
  "detail-type": "Scheduled Event",
  "source": "aws.events",
  "account": "891377304437",
  "time": "2024-10-11T12:00:00Z",
  "region": "ca-central-1",
  "resources": [
    "arn:aws:scheduler:ca-central-1:891377304437:schedule/default/run-log-insights-query"
  ],
  "detail": {}
}






#lambda refined 


import boto3
import json
from datetime import datetime, timedelta
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

# Create a CloudWatch Logs client
client = boto3.client('logs')
ec2_client = boto3.client('ec2')

# Replace with your Slack Webhook URL
slack_webhook_url = 'https://hooks.slack.com/services/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'

# Replace with your specific VPC ID and region
vpc_id = 'vpc-12345678'
region_name = 'ca-central-1'

def lambda_handler(event, context):
    # Define the CloudWatch Logs Insights queries
    log_group_name = 'vpcflowlogs'

    # Time range for the queries (last 5 minutes)
    start_time = int((datetime.utcnow() - timedelta(minutes=5)).timestamp() * 1000)
    end_time = int(datetime.utcnow().timestamp() * 1000)

    # Define queries with updated Rejected Connections query
    queries = {
        'Rejected Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol, dstPort
        | filter action = "REJECT"
        | stats count() as rejection_count by srcAddr, dstAddr, dstPort
        | sort rejection_count desc
        | filter rejection_count >= 5
        | limit 10
        ''',
        'Accepted SSH Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol, dstPort
        | filter action = "ACCEPT" and dstPort = 22
        | stats count() as ssh_count by srcAddr, dstAddr
        | sort ssh_count desc
        | limit 10
        ''',
        'Spoofed IP Addresses': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol
        | filter srcAddr in ["0.0.0.0", "255.255.255.255"]
        | stats count() as spoofed_count by srcAddr, dstAddr
        | sort spoofed_count desc
        | limit 10
        ''',
        'General Rejected Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol
        | filter action = "REJECT"
        | stats count() as general_rejection_count by srcAddr, action
        | sort general_rejection_count desc
        | limit 10
        ''',
        'Large Data Transfers': '''
        fields @timestamp, srcAddr, dstAddr, bytes
        | filter bytes > 1000000
        | stats sum(bytes) as total_bytes by srcAddr, dstAddr
        | sort total_bytes desc
        | limit 10
        ''',
        'High Packet Count': '''
        fields @timestamp, srcAddr, dstAddr, packets
        | filter packets > 5000
        | stats sum(packets) as total_packets by srcAddr, dstAddr
        | sort total_packets desc
        | limit 10
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

    # Format Slack message attachments with colors and add contextual details
    def format_slack_message(query_label, results, color, no_data_message="No data found.", show_instance_details=False):
        # Handle no data condition
        if not results['results']:
            formatted_results = no_data_message
        else:
            # For Rejected Connections, include Source IP, Destination IP, Port, and Count
            if query_label == 'Rejected Connections':
                formatted_results = f"{'Source IP':<18} {'Dest IP':<18} {'Port':<6} {'Count':<5}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = next(item['value'] for item in row if item['field'] == 'srcAddr')
                    dst_addr = next(item['value'] for item in row if item['field'] == 'dstAddr')
                    dst_port = next(item['value'] for item in row if item['field'] == 'dstPort')
                    count = next(item['value'] for item in row if 'count' in item['field'])
                    formatted_results += f"{src_addr:<18} {dst_addr:<18} {dst_port:<6} {count:<5}\n"
            else:
                formatted_results = f"{'Source IP':<20} {'Count':<5}\n" + "-" * 20 + "\n"
                for row in results['results']:
                    src_addr = next(item['value'] for item in row if item['field'] == 'srcAddr')
                    count = next(item['value'] for item in row if 'count' in item['field'])
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
        
        # Add no data message based on query type
        if query_label == 'High Packet Count':
            no_data_message = "No high packet counts found in the last 5 minutes."
        elif query_label == 'Large Data Transfers':
            no_data_message = "No large data transfers found in the last 5 minutes."
        else:
            no_data_message = "No data found."

        if query_label == 'Rejected Connections':
            color = "#FF0000"  # Red for high rejected connections
        elif query_label == 'Accepted SSH Connections':
            color = "#FFFF00"  # Yellow for accepted SSH connections
            show_instance_details = True  # Show instance details only for SSH
        else:
            color = "#36a64f"  # Green for other queries

        # Format the message and add it to the attachments
        attachments.append(format_slack_message(query_label, results, color, no_data_message, show_instance_details))

    # Send message to Slack
    slack_payload = {
        "attachments": attachments,
        "channel": "#alerts"  # Change this to your Slack channel
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








#aetonix 


import boto3
import json
from datetime import datetime, timedelta
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

# Create a CloudWatch Logs client
client = boto3.client('logs')
ec2_client = boto3.client('ec2')

# Replace with your Slack Webhook URL
slack_webhook_url = 'https://hooks.slack.com/services/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'

# Replace with your specific VPC ID and region
vpc_id = 'vpc-b7412fdf'
region_name = 'ca-central-1'

def lambda_handler(event, context):
    # Define the CloudWatch Logs Insights queries
    log_group_name = 'Prod/vpcflowlogs'

    # Time range for the queries (last 5 minutes)
    start_time = int((datetime.utcnow() - timedelta(minutes=5)).timestamp() * 1000)
    end_time = int(datetime.utcnow().timestamp() * 1000)

    # Define queries with updated Rejected Connections query
    queries = {
        'Rejected Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol, dstPort
        | filter action = "REJECT"
        | stats count() as rejection_count by srcAddr, dstAddr, dstPort
        | sort rejection_count desc
        | filter rejection_count >= 5
        | limit 10
        ''',
        'Accepted SSH Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol, dstPort
        | filter action = "ACCEPT" and dstPort = 22
        | stats count() as ssh_count by srcAddr, dstAddr
        | sort ssh_count desc
        | limit 10
        ''',
        'Spoofed IP Addresses': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol
        | filter srcAddr in ["0.0.0.0", "255.255.255.255"]
        | stats count() as spoofed_count by srcAddr, dstAddr
        | sort spoofed_count desc
        | limit 10
        ''',
        'General Rejected Connections': '''
        fields @timestamp, srcAddr, dstAddr, action, protocol
        | filter action = "REJECT"
        | stats count() as general_rejection_count by srcAddr, action
        | sort general_rejection_count desc
        | limit 10
        ''',
        'Large Data Transfers': '''
        fields @timestamp, srcAddr, dstAddr, bytes
        | filter bytes > 1000000
        | stats sum(bytes) as total_bytes by srcAddr, dstAddr
        | sort total_bytes desc
        | limit 10
        ''',
        'High Packet Count': '''
        fields @timestamp, srcAddr, dstAddr, packets
        | filter packets > 5000
        | stats sum(packets) as total_packets by srcAddr, dstAddr
        | sort total_packets desc
        | limit 10
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
            # For Rejected Connections, include Source IP, Destination IP, Port, and Count
            if query_label == 'Rejected Connections':
                formatted_results = f"{'Source IP':<18} {'Dest IP':<18} {'Port':<6} {'Count':<5}\n" + "-" * 50 + "\n"
                for row in results['results']:
                    src_addr = safe_extract(row, 'srcAddr')
                    dst_addr = safe_extract(row, 'dstAddr')
                    dst_port = safe_extract(row, 'dstPort')
                    count = safe_extract(row, 'rejection_count')
                    formatted_results += f"{src_addr:<18} {dst_addr:<18} {dst_port:<6} {count:<5}\n"
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
        
        # Add no data message based on query type
        if query_label == 'High Packet Count':
            no_data_message = "No high packet counts found in the last 5 minutes."
        elif query_label == 'Large Data Transfers':
            no_data_message = "No large data transfers found in the last 5 minutes."
        else:
            no_data_message = "No data found."

        if query_label == 'Rejected Connections':
            color = "#FF0000"  # Red for high rejected connections
        elif query_label == 'Accepted SSH Connections':
            color = "#FFFF00"  # Yellow for accepted SSH connections
            show_instance_details = True  # Show instance details only for SSH
        else:
            color = "#36a64f"  # Green for other queries

        # Format the message and add it to the attachments
        attachments.append(format_slack_message(query_label, results, color, no_data_message, show_instance_details))

    # Send message to Slack
    slack_payload = {
        "attachments": attachments,
        "channel": "#alerts"  # Change this to your Slack channel
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

