import boto3

def lambda_handler(event, context):
    # Create CloudWatch client
    cloudwatch = boto3.client('cloudwatch')

    # Correctly extract instance ID from EventBridge event for EC2 Instance State-change Notification
    instance_id = event['detail']['instance-id']
    
    # Define the alarm name and description
    alarm_name = f"CPUUtilization_Alarm_{instance_id}"
    alarm_description = f"Alarm when CPU exceeds 70% for instance {instance_id}"

    # Specify actions for different states
    action_sns_topic_arn = 'arn:aws:sns:ca-central-1:891377304437:my-sns-autoscaling-notification'  # Ensure this ARN is correct
    ok_actions = [action_sns_topic_arn]
    alarm_actions = [action_sns_topic_arn]
    insufficient_data_actions = [action_sns_topic_arn]

    # Create or update a CloudWatch alarm for the CPU utilization
    cloudwatch.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=alarm_description,
        ActionsEnabled=True,
        OKActions=ok_actions,
        AlarmActions=alarm_actions,
        InsufficientDataActions=insufficient_data_actions,
        MetricName='CPUUtilization',
        Namespace='AWS/EC2',
        Statistic='Average',
        Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
        Period=300,  # 5 minutes
        EvaluationPeriods=1,
        Threshold=70.0,
        ComparisonOperator='GreaterThanThreshold'
    )

    return {
        'message': f'Successfully created or updated CloudWatch alarm {alarm_name}'
    }
