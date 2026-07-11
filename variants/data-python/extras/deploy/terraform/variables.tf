# Inputs for the Terraform config. Pass them via a gitignored terraform.tfvars,
# `-var` flags, or TF_VAR_* environment variables. Never put secrets in a
# committed .tfvars - source them from the environment or a secrets manager.

variable "app_name" {
  description = "Name of the pipeline / job."
  type        = string
}

variable "region" {
  description = "Provider region to deploy into."
  type        = string
}

variable "image" {
  description = "Container image reference (repo:tag, or repo@digest for a pinned build) the scheduler runs."
  type        = string
  default     = ""
}

variable "data_bucket" {
  description = "Object-store bucket for the pipeline's inputs and outputs."
  type        = string
  default     = ""
}

variable "schedule" {
  description = "Cron expression for how often the job runs (e.g. '0 3 * * *' for daily at 03:00)."
  type        = string
  default     = ""
}
