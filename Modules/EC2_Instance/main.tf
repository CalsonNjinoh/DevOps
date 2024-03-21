resource "aws_instance" "instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids


  tags = {
    Name = var.instance_name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name                = "${var.instance_name}-cpu-utilization-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 75
  alarm_description         = "This alarm helps to monitor the CPU utilization of an EC2 instance. Depending on the application, consistently high utilization levels might be normal. But if performance is degraded, and the application is not constrained by disk I/O, memory, or network resources, then a maxed-out CPU might indicate a resource bottleneck or application performance problems. High CPU utilization might indicate that an upgrade to a more CPU intensive instance is required. If detailed monitoring is enabled, you can change the period to 60 seconds instead of 300 seconds. For more information, see [Enable or turn off detailed monitoring for your instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html)"
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn] # ARN for action to take (e.g., SNS Topic ARN)
  ok_actions                = [var.ok_action_arn]
  insufficient_data_actions = [var.insufficient_data_action_arn]

  dimensions = {
    InstanceId = aws_instance.instance.id
  }

  tags = {
    Name = "${var.instance_name}-cpu-utilization-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_usage_alarm" {
  alarm_name                = "${var.instance_name}-disk-usage-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "disk_used_percent" # Ensure this matches your custom metric
  namespace                 = "Custom"            # Adjust based on where your metric is stored
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80 # Alert if disk usage is >= 80%
  alarm_description         = "This alarm monitors the disk_used_percent metric on an EC2 instance, crucial for ensuring there is adequate disk space for efficient operation and stability. High disk utilization warns that the instance is running out of space, potentially leading to application errors, inability to write logs or data, and system performance degradation. Unlike metrics such as CPU or memory utilization, which might spike temporarily under load, consistently high disk usage suggests an urgent need for cleanup, data archiving, or disk expansion to prevent service disruption. Detailed monitoring enables closer observation of disk usage trends, aiding in proactive management and resolution of disk space issues. Effective disk space management is key to maintaining optimal application performance and system reliability. For strategies on managing disk space and performance, consult the AWS documentation on https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Storage.html"
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]
  ok_actions                = [var.ok_action_arn]
  insufficient_data_actions = [var.insufficient_data_action_arn]

  dimensions = {
    InstanceId = aws_instance.instance.id
  }
}

resource "aws_cloudwatch_metric_alarm" "system_status_check_failure" {
  alarm_name                = "${var.instance_name}-system-status-check-failure"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 0
  alarm_description         = "This alarm monitors the System Status Check failure of an EC2 instance. AWS performs system status checks to detect underlying problems with the instance that require AWS involvement to repair. A failure in system status checks can indicate issues with the instance's underlying hardware or the AWS infrastructure, leading to problems like loss of network connectivity, loss of system power, and software issues on the physical host. Consistent failures might necessitate stopping and starting the instance (which migrates it to a new physical host) or contacting AWS Support. Unlike CPU utilization, which might vary based on application load, system status check failures are always indicative of issues that need immediate attention. For instances with detailed monitoring enabled, data granularity increases, allowing for more precise diagnosis periods. For more information on system status checks and how to respond to them, see Status Checks for Your Instances and Troubleshooting Instances with Failed Status Checks."
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]
  ok_actions                = [var.ok_action_arn]
  insufficient_data_actions = [var.insufficient_data_action_arn]

  dimensions = {
    InstanceId = aws_instance.instance.id
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_status_check_failure" {
  alarm_name                = "${var.instance_name}-instance-status-check-failure"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 0
  alarm_description         = "This alarm monitors Instance Status Check failures, indicating operational issues with an EC2 instance's software or network configuration, such as corrupted filesystems or incorrect startup settings. Unlike variable metrics like CPU utilization, status check failures signify immediate operational problems requiring intervention, potentially resolved by instance configuration review, system log investigation, or restarting the instance. Enabling detailed monitoring provides data in 1-minute intervals, allowing for quicker issue detection and resolution. Persistent issues might necessitate instance replacement or AWS Support consultation. For detailed guidance on addressing status check failures, refer to AWS documentation on Status Checks for Your Instances and Troubleshooting Instances with Failed Status Checks."
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]
  ok_actions                = [var.ok_action_arn]
  insufficient_data_actions = [var.insufficient_data_action_arn]

  dimensions = {
    InstanceId = aws_instance.instance.id
  }
}
resource "aws_cloudwatch_metric_alarm" "disk_space_available" {
  alarm_name                = "${var.instance_name}-disk-space-available"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  metric_name               = "disk_free_space" # Make sure this matches your custom metric
  namespace                 = "CWAgent"         # Default namespace for CloudWatch Agent metrics
  period                    = 300
  statistic                 = "Minimum"
  threshold                 = 5000 # Threshold in Megabytes, adjust as needed
  alarm_description         = "This alarm monitors the available disk space on an EC2 instance, crucial for ensuring that your applications have enough space to operate effectively and store data. Running low on disk space can lead to a variety of issues, including application errors, database crashes, and degraded performance. Unlike metrics such as CPU utilization, which might vary widely based on the application load and still indicate normal operation, low available disk space is generally a clear signal that action is needed to prevent outages or performance degradation. Actions might include cleaning up unnecessary files, increasing the disk size, or optimizing application data management strategies. If detailed monitoring is enabled, the period for this metric can be set to 60 seconds instead of 300 seconds, providing more timely alerts and allowing for quicker remediation. For guidance on managing disk space and setting up appropriate monitoring, see Amazon CloudWatch User Guide."
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]
  ok_actions                = [var.ok_action_arn]
  insufficient_data_actions = [var.insufficient_data_action_arn]

  dimensions = {
    InstanceId = aws_instance.instance.id
    # Add any other relevant dimensions, such as the path if you are monitoring specific volumes
  }

  tags = {
    Name = "${var.instance_name}-disk-space-available"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name                = "${var.instance_name}-memory-utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "mem_used_percent" # This should match your custom metric
  namespace                 = "CWAgent"          # Default namespace for CloudWatch Agent metrics
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80 # Alert if memory utilization is greater than 80%
  alarm_description         = "This alarm monitors EC2 memory utilization, essential for preventing performance issues or outages by ensuring applications have enough memory. High memory usage may indicate excessive consumption, leading to potential performance drops or system crashes. Unlike fluctuating metrics like CPU utilization, consistently high memory utilization warrants investigation to discern if it's due to normal high load or signals a need for resizing or optimization. Detailed monitoring offers 1-minute interval data, offering insights into memory usage patterns for prompt issue addressing. For guidance on memory management and optimization, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring_ec2.html.."
  actions_enabled           = true
  alarm_actions             = [var.alarm_action_arn]
  ok_actions                = [var.ok_action_arn]
  insufficient_data_actions = [var.insufficient_data_action_arn]

  dimensions = {
    InstanceId = aws_instance.instance.id
  }

  tags = {
    Name = "${var.instance_name}-memory-utilization"
  }
}
