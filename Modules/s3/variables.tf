variable "buckets" {
  type = list(object({
    name           = string
    block_public   = bool
  }))
  description = "List of buckets with names and public access settings"
}
