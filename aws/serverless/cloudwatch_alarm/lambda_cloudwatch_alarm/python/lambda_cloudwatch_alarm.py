import boto3

def lambda_function_exists(lambda_client, function_name):
    try:
        lambda_client.get_function(FunctionName=function_name)
        return True
    except lambda_client.exceptions.ResourceNotFoundException:
        return False

def alarm_exists(cloudwatch_client, alarm_name):
    existing_alarms = cloudwatch_client.describe_alarms(AlarmNames=[alarm_name])
    return len(existing_alarms['MetricAlarms']) > 0

def create_cloudwatch_alarm(region, function_name, sns_topic_arn):
    cloudwatch_client = boto3.client('cloudwatch', region_name=region)
    lambda_client = boto3.client('lambda', region_name=region)

    alarm_name = f"lambda-{function_name}-error-alert"

    if not lambda_function_exists(lambda_client, function_name):
        print(f"No Lambda function named {function_name} found in region {region}, skipping...")
        return

    if alarm_exists(cloudwatch_client, alarm_name):
        print(f"Alarm already exists for {function_name}, skipping...")
        return

    cloudwatch_client.put_metric_alarm(
        # [Alarm creation details as previously provided...]
    )
    print(f"CloudWatch alarm created for function {function_name} in region {region}.")

def main():
    region = input("Enter the AWS region: ")
    sns_client = boto3.client('sns', region_name=region)

    # Fetching the SNS topic ARN
    sns_topic_arn = None
    for topic in sns_client.list_topics()['Topics']:
        if topic['TopicArn'].endswith(':Notifications'):
            sns_topic_arn = topic['TopicArn']
            break

    if not sns_topic_arn:
        raise Exception("SNS topic 'Notifications' not found")

    while True:
        function_name = input("Enter the Lambda function name (or 'exit' to finish): ")
        if function_name.lower() == 'exit':
            break
        create_cloudwatch_alarm(region, function_name, sns_topic_arn)

if __name__ == "__main__":
    main()
