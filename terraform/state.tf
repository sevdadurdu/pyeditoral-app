module "s3_bucket_for_terraform_states_pyeditoral" {
  source                  = "terraform-aws-modules/s3-bucket/aws"
  version                 = "4.0.1"
  bucket                  = "terraform-states-pyeditoral"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  force_destroy = false
  tags          = local.tags
}

module "dynamodb_table_for_terraform_state_lock" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  version  = "4.0.0"
  name     = "terraform-state-lock"
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}