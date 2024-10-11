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
