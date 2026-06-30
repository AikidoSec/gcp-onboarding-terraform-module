variable "organization_id" {
  description = "The Google Cloud organization ID to connect to Aikido."
  type        = string
}

variable "project_id" {
  description = "The Google Cloud project ID that will host the Workload Identity Pool for the organization."
  type        = string
}

variable "project_number" {
  description = "The Google Cloud project number for the host project, used in Workload Identity principal paths."
  type        = string
}

variable "disable_services_on_destroy" {
  description = "Whether to disable the Google APIs enabled by this module when it is destroyed."
  type        = bool
  default     = false
}

variable "enable_host_project_services" {
  description = "Whether to enable the full set of Google APIs in the host project. The three APIs required for Workload Identity Federation are always enabled regardless of this setting."
  type        = bool
  default     = false
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

variable "workload_identity_pool_description" {
  description = "Description for the Aikido Workload Identity Pool."
  type        = string
  default     = "Workload Identity Pool for Aikido Security integration"
}

variable "workload_identity_pool_provider_id" {
  description = "ID for the Aikido AWS Workload Identity Provider."
  type        = string
  default     = "aikido-aws-provider"
}

variable "workload_identity_pool_provider_display_name" {
  description = "Display name for the Aikido AWS Workload Identity Provider."
  type        = string
  default     = "Aikido AWS Provider"
}

variable "workload_identity_pool_provider_description" {
  description = "Description for the Aikido AWS Workload Identity Provider."
  type        = string
  default     = "Workload Identity Provider for Aikido Security's AWS account"
}

variable "aikido_aws_account_id" {
  description = "Aikido's AWS account ID used to scope the Workload Identity Provider."
  type        = string
  default     = "881830977366"
}

variable "aikido_project_role_arns" {
  description = "Aikido AWS role ARNs that should receive organization-level read access for cloud and project-discovery scanning."
  type        = set(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-gcp-cloud-findings-role-1muvqxle",
  ]
}

variable "aikido_artifact_registry_role_arns" {
  description = "Aikido AWS role ARNs that should receive organization-level Artifact Registry read access for container scanning."
  type        = set(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-container-image-scanner-role-pb0qotst",
  ]
}

variable "org_roles" {
  description = "Organization-level IAM roles granted to Aikido's cloud scanning role."
  type        = set(string)
  default = [
    "roles/viewer",
    "roles/iam.securityReviewer",
    "roles/resourcemanager.folderViewer",
  ]
}

variable "enable_artifact_registry_reader" {
  description = "Whether to grant organization-level Artifact Registry read access to Aikido's container scanning role."
  type        = bool
  default     = false
}

variable "enable_vm_scanning" {
  description = "Whether to provision the IAM roles and bindings required for GCP VM scanning."
  type        = bool
  default     = false
}

variable "gcp_vm_scanner_service_account_email" {
  description = "Email of the Aikido-managed GCP VM scanner service account that should receive VM scanning access."
  type        = string
  default     = "aikido-vm-scanner@aikido-vm-scanning.iam.gserviceaccount.com"

  validation {
    condition     = !var.enable_vm_scanning || trimspace(var.gcp_vm_scanner_service_account_email) != ""
    error_message = "gcp_vm_scanner_service_account_email must be set when enable_vm_scanning is true."
  }
}

variable "vm_scanner_role_id" {
  description = "ID for the custom role that grants Aikido VM scanning access."
  type        = string
  default     = "aikidoSecurityVmScannerRole"
}

variable "vm_scanner_role_title" {
  description = "Title for the custom role that grants Aikido VM scanning access."
  type        = string
  default     = "Aikido Security VM Scanner Role"
}

variable "vm_scanner_role_description" {
  description = "Description for the custom role that grants Aikido VM scanning access."
  type        = string
  default     = "Permissions required for Aikido VM snapshot scanning"
}

variable "vm_scanner_delete_role_id" {
  description = "ID for the custom role that grants Aikido permission to delete only its own VM snapshots."
  type        = string
  default     = "aikidoSecurityVmScannerSnapshotDeleteRole"
}

variable "vm_scanner_delete_role_title" {
  description = "Title for the custom role that grants Aikido permission to delete only its own VM snapshots."
  type        = string
  default     = "Aikido Security VM Scanner Snapshot Delete Role"
}

variable "vm_scanner_delete_role_description" {
  description = "Description for the custom role that grants Aikido permission to delete only its own VM snapshots."
  type        = string
  default     = "Delete permissions for Aikido-managed VM snapshots"
}
