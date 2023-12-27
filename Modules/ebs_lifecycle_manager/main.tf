resource "aws_dlm_lifecycle_policy" "ebs_lifecycle" {
  description        = "EBS Snapshot Lifecycle Policy"
  execution_role_arn = aws_iam_role.ebs_lifecycle_role.arn
  tags = var.tags
  policy_details {
    resource_types = ["VOLUME"]
    schedule {
      name = var.schedule_name
      create_rule {
        interval      = var.snapshot_interval
        interval_unit = "HOURS"
        times         = [var.snapshot_time]
      }
      retain_rule {
        count = var.snapshot_retention_count
      }
      copy_tags = var.copy_tags
    }
    target_tags = var.target_tags
  }
  state = "ENABLED"
}
