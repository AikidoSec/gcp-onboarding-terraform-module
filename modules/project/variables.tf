variable "project_id" {
  description = "The Google Cloud project ID to connect to Aikido."
  type        = string
}

variable "project_number" {
  description = "The Google Cloud project number, used in Workload Identity principal paths."
  type        = string
}

variable "disable_services_on_destroy" {
  description = "Whether to disable the Google APIs enabled by this module when it is destroyed."
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
  description = "Aikido AWS role ARNs that should receive project-level read access for cloud scanning."
  type        = set(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-gcp-cloud-findings-role-1muvqxle",
  ]
}

variable "aikido_artifact_registry_role_arns" {
  description = "Aikido AWS role ARNs that should receive Artifact Registry read access for container scanning."
  type        = set(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-container-image-scanner-role-pb0qotst",
  ]
}

variable "project_roles" {
  description = "Project-level IAM roles granted to Aikido's cloud scanning role."
  type        = set(string)
  default = [
    "roles/viewer",
    "roles/iam.securityReviewer",
  ]
}

variable "enable_vm_scanning" {
  description = "Whether to provision the GCP resources required for Aikido VM scanning."
  type        = bool
  default     = false
}

variable "vm_scanning_bucket_name" {
  description = "Name of the Cloud Storage bucket used for exported VM images."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_vm_scanning || var.vm_scanning_bucket_name != null
    error_message = "vm_scanning_bucket_name must be set when enable_vm_scanning is true."
  }
}

variable "vm_scanning_bucket_location" {
  description = "Location of the Cloud Storage bucket used for exported VM images."
  type        = string
  default     = null

  validation {
    condition     = !var.enable_vm_scanning || var.vm_scanning_bucket_location != null
    error_message = "vm_scanning_bucket_location must be set when enable_vm_scanning is true."
  }
}

variable "vm_scanning_bucket_storage_class" {
  description = "Storage class for the VM scanning export bucket."
  type        = string
  default     = "STANDARD"
}

variable "vm_scanning_bucket_force_destroy" {
  description = "Whether to delete objects from the VM scanning export bucket when destroying it."
  type        = bool
  default     = false
}

variable "vm_scanning_bucket_public_access_prevention" {
  description = "Public access prevention mode for the VM scanning export bucket."
  type        = string
  default     = "enforced"
}

variable "vm_scanning_bucket_uniform_bucket_level_access" {
  description = "Whether to enable uniform bucket-level access on the VM scanning export bucket."
  type        = bool
  default     = true
}

variable "aikido_vm_scanning_role_arns" {
  description = "Aikido AWS role ARNs that should receive access for GCP VM scanning."
  type        = set(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/gcp-vm-scanner-role",
  ]
}

variable "vm_scanning_role_id" {
  description = "ID for the custom role used by Aikido VM scanning."
  type        = string
  default     = "aikidoSecurityVmScannerRole"
}

variable "vm_scanning_snapshot_delete_role_id" {
  description = "ID for the custom role used only for deleting Aikido-managed VM snapshots."
  type        = string
  default     = "aikidoSecurityVmScannerSnapshotDeleteRole"
}
