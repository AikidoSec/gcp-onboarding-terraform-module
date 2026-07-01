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

variable "vm_scanner_role_id" {
  description = "ID for the VM scanner custom role created by the example."
  type        = string
  default     = "aikidoSecurityVmScannerRole"
}

variable "vm_scanner_delete_role_id" {
  description = "ID for the VM scanner snapshot delete custom role created by the example."
  type        = string
  default     = "aikidoSecurityVmScannerSnapshotDeleteRole"
}

variable "aikido_aws_account_id" {
  description = "Aikido AWS account ID used to scope the Workload Identity Provider."
  type        = string
  default     = "881830977366"
}

variable "aikido_project_role_arns" {
  description = "Aikido AWS role ARNs that should receive organization-level read access."
  type        = list(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-gcp-cloud-findings-role-1muvqxle",
  ]
}

variable "aikido_artifact_registry_role_arns" {
  description = "Aikido AWS role ARNs that should receive Artifact Registry read access."
  type        = list(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-container-image-scanner-role-pb0qotst",
  ]
}

variable "workload_identity_pool_id" {
  description = "ID for the Aikido Workload Identity Pool."
  type        = string
  default     = "aikido-identity-pool"
}

variable "workload_identity_pool_display_name" {
  description = "Display name for the Aikido Workload Identity Pool."
  type        = string
  default     = "Aikido Identity Pool"
}
