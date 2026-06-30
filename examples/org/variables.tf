variable "organization_id" {
  description = "The Google Cloud organization ID to connect to Aikido."
  type        = string
}

variable "host_project_id" {
  description = "The Google Cloud project ID that will host the Workload Identity Pool."
  type        = string
}

variable "host_project_number" {
  description = "The Google Cloud project number for the host project."
  type        = string
}

variable "enable_artifact_registry_reader" {
  description = "Whether to grant Artifact Registry read access."
  type        = bool
  default     = false
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
