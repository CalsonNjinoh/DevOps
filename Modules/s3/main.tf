resource "aws_s3_bucket" "bucket" {
  for_each = { for b in var.buckets : b.name => b }

  bucket = each.value.name
  // Additional configurations...
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = { for b in var.buckets : b.name => b if b.block_public }

  bucket = aws_s3_bucket.bucket[each.key].id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}
