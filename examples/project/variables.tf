variable "project_id" {
  description = "The Google Cloud project ID to connect to Aikido."
  type        = string
}

variable "project_number" {
  description = "The Google Cloud project number."
  type        = string
}

variable "enable_vm_scanning" {
  description = "Whether to provision IAM roles and bindings for GCP VM scanning."
  type        = bool
  default     = false
}

variable "gcp_vm_scanner_service_account_email" {
  description = "Email of the Aikido-managed GCP VM scanner service account."
  type        = string
  default     = ""
}
