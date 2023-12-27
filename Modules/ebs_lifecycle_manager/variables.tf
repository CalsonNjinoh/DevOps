variable "schedule_name" {
  description = "Name of the snapshot schedule"
  type        = string
}
variable "snapshot_interval" {
  description = "Interval in hours for the snapshot"
  type        = number
}
variable "snapshot_time" {
  description = "Time of day when the snapshot is taken"
  type        = string
}
variable "snapshot_retention_count" {
  description = "Number of snapshots to retain"
  type        = number
}
variable "copy_tags" {
  description = "Whether to copy tags from the volume to the snapshot"
  type        = bool
  default     = false
}
variable "target_tags" {
  description = "A map of tags, each pair of which must exactly match a pair on the desired volumes"
  type        = map(string)
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  
}
