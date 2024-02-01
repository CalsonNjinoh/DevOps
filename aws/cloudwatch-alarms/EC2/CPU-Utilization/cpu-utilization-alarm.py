import boto3

def create_cpu_utilization_alarm(region, instance_id, sns_topic_arn):
    cloudwatch_client = boto3.client('cloudwatch', region_name=region)

    # Constructing the alarm name
    metric_name = "CPUUtilization"
    alarm_name = f"EC2-{instance_id}-{metric_name}"

    cloudwatch_client.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=f"Alarm when CPU Utilization exceeds 90% for {instance_id}",
        ActionsEnabled=True,
        AlarmActions=[sns_topic_arn],
        OKActions=[sns_topic_arn],
        InsufficientDataActions=[sns_topic_arn],
        MetricName=metric_name,
        Namespace='AWS/EC2',
        Statistic='Average',
        Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
        Period=60,  # 1 minute
        EvaluationPeriods=1,
        Threshold=90.0,
        ComparisonOperator='GreaterThanOrEqualToThreshold',
        TreatMissingData='missing',
    )
    print(f"CloudWatch alarm created for instance {instance_id} in region {region}.")

def main():
    region = input("Enter the AWS region: ")
    sns_client = boto3.client('sns', region_name=region)

    sns_topic_arn = None
    for topic in sns_client.list_topics()['Topics']:
        if topic['TopicArn'].endswith(':Notifications'):
            sns_topic_arn = topic['TopicArn']
            break

    if not sns_topic_arn:
        raise Exception("SNS topic 'Notifications' not found")

    while True:
        instance_id = input("Enter the EC2 Instance ID (or 'exit' to finish): ")
        if instance_id.lower() == 'exit':
            break
        create_cpu_utilization_alarm(region, instance_id, sns_topic_arn)

if __name__ == "__main__":
    main()

