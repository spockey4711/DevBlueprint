# Terraform skeleton for provisioning this app's infrastructure. The provider and
# resources are host-specific, so the concrete blocks are commented out - fill in
# the ones your target needs (see docs/ops/deployment.md). The workflow is always:
# `terraform init`, then `terraform plan`, and only then `terraform apply`.
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
  #   key    = "<app>/terraform.tfstate"
  #   region = "<region>"
  # }
}

# provider "<provider>" {
#   region = var.region
# }

# Example shape: a container service running the image built from this repo's
# Dockerfile (the OTP release). Replace with your provider's real resource types.
#
# resource "<provider>_service" "app" {
#   name  = var.app_name
#   image = var.image
#   port  = 4000
#
#   # Non-secret config inline; pull secrets (SECRET_KEY_BASE, DATABASE_URL) from a
#   # secrets manager, never from plain variables committed to the repo.
#   env = {
#     MIX_ENV    = "prod"
#     PHX_SERVER = "true"
#   }
# }
