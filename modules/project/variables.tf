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

variable "enable_artifact_registry_reader" {
  description = "Whether to grant Artifact Registry read access to Aikido's container scanning role."
  type        = bool
  default     = false
}
