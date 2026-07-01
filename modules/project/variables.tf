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

variable "aikido_region" {
  description = "Aikido instance region. Controls the default AWS principals used for the GCP cloud connection. Valid values: \"eu\" (default, app.aikido.dev), \"us\" (app.us.aikido.dev), \"me\" (app.me.aikido.dev), \"au\" (app.au.aikido.dev)."
  type        = string
  default     = "eu"

  validation {
    condition     = contains(["eu", "us", "me", "au"], var.aikido_region)
    error_message = "aikido_region must be one of: \"eu\", \"us\", \"me\", \"au\"."
  }
}

variable "aikido_aws_account_id" {
  description = "Aikido's AWS account ID used to scope the Workload Identity Provider. Overrides the account selected by aikido_region when set."
  type        = string
  default     = null
}

variable "aikido_project_role_arns" {
  description = "Aikido AWS role ARNs that should receive project-level read access for cloud scanning. Overrides the defaults selected by aikido_region when set."
  type        = set(string)
  default     = null
}

variable "aikido_artifact_registry_role_arns" {
  description = "Aikido AWS role ARNs that should receive Artifact Registry read access for container scanning. Overrides the defaults selected by aikido_region when set."
  type        = set(string)
  default     = null
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
