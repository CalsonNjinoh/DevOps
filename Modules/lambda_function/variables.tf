variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "source_code_hash" {
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name where the .zip file containing your deployment package is stored"
  type        = string
}

variable "s3_key" {
  description = "S3 key of the .zip file containing your deployment package"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role that Lambda assumes when it executes your function"
  type        = string
}

