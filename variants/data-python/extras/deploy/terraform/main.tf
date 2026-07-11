# Terraform skeleton for provisioning this pipeline's infrastructure: the compute
# a scheduler dispatches the job image to, and the object storage the pipeline
# reads and writes. The provider and resources are host-specific, so the concrete
# blocks are commented out - fill in the ones your target needs (see
# docs/ops/deployment.md). The workflow is always: `terraform init`, then
# `terraform plan`, and only then `terraform apply`.
#
# State: configure a remote backend (S3 + a DynamoDB lock, GCS, or Terraform Cloud)
# before anyone else touches this - local state does not survive a team, and a lost
# state file orphans real infrastructure.

terraform {
  required_version = ">= 1.6"

  # required_providers {
  #   <provider> = {
  #     source  = "<namespace>/<provider>"
  #     version = "~> <major>.<minor>"
  #   }
  # }

  # backend "s3" {
  #   bucket = "<state-bucket>"
  #   key    = "<pipeline>/terraform.tfstate"
  #   region = "<region>"
  # }
}

# provider "<provider>" {
#   region = var.region
# }

# Example shape 1: object storage for the pipeline's inputs and outputs. Replace
# with your provider's real bucket resource (aws_s3_bucket, google_storage_bucket).
#
# resource "<provider>_bucket" "data" {
#   name = var.data_bucket
#   # Enable versioning so a bad run does not overwrite good data irrecoverably.
# }

# Example shape 2: a batch/job definition that runs the image built from this
# repo's Dockerfile to completion (AWS Batch job definition, Cloud Run job, ...).
# This is a job, not a service - there is no port and no health check; the
# scheduler treats a non-zero exit as a failed run.
#
# resource "<provider>_batch_job" "pipeline" {
#   name  = var.app_name
#   image = var.image
#
#   # Non-secret config inline; pull secrets (warehouse and object-store creds)
#   # from a secrets manager, never from plain variables committed to the repo.
#   env = {
#     APP_ENV   = "production"
#     S3_BUCKET = var.data_bucket
#   }
# }

# Example shape 3: the schedule that triggers the job (cron trigger, EventBridge
# rule, Cloud Scheduler job). Wire it to the job definition above.
#
# resource "<provider>_schedule" "pipeline" {
#   name                = "${var.app_name}-daily"
#   schedule_expression = var.schedule
# }
