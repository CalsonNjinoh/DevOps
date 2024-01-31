import boto3

def create_cloudwatch_alarm(region, function_name, sns_topic_arn):
    cloudwatch_client = boto3.client('cloudwatch', region_name=region)

    alarm_name = f"lambda{function_name}ErrorAlert"
    cloudwatch_client.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=f"Alarm for function {function_name} errors",
        ActionsEnabled=True,
        AlarmActions=[sns_topic_arn],  # Actions for when the alarm state is 'In Alarm'
        OKActions=[sns_topic_arn],     # Actions for when the alarm state returns to 'OK'
        MetricName='Errors',
        Namespace='AWS/Lambda',
        Statistic='Average',
        Dimensions=[{'Name': 'FunctionName', 'Value': function_name}],
        Period=300,  # 5 minutes
        EvaluationPeriods=1,
        Threshold=2,
        ComparisonOperator='GreaterThanOrEqualToThreshold',
        TreatMissingData='missing',
    )

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
        print(f"CloudWatch alarm created for function {function_name} in region {region}.")

if __name__ == "__main__":
    main()
