variable "project_id" {
  description = "The Google Cloud project ID where Aikido will be installed."
  type        = string
}

variable "project_number" {
  description = "The Google Cloud project number used in Workload Identity principal paths."
  type        = string
}

variable "disable_services_on_destroy" {
  description = "Whether Google APIs enabled by this module should be disabled when the module is destroyed."
  type        = bool
  default     = false
}

variable "workload_identity_pool_location" {
  description = "Location for the Workload Identity Pool."
  type        = string
  default     = "global"
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
  description = "AWS account ID used by Aikido Security."
  type        = string
  default     = "881830977366"
}

variable "aikido_project_role_arns" {
  description = "AWS role ARNs from Aikido that should receive project-level read access."
  type        = set(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-gcp-cloud-findings-role-1muvqxle",
  ]
}

variable "aikido_artifact_registry_role_arns" {
  description = "AWS role ARNs from Aikido that should receive Artifact Registry read access."
  type        = set(string)
  default = [
    "arn:aws:sts::881830977366:assumed-role/lambda-container-image-scanner-role-pb0qotst",
  ]
}

variable "project_roles" {
  description = "Project-level IAM roles granted to Aikido's cloud findings role."
  type        = set(string)
  default = [
    "roles/viewer",
    "roles/iam.securityReviewer",
  ]
}

variable "enable_artifact_registry_reader" {
  description = "Whether to grant Artifact Registry read access to Aikido's container scanner role."
  type        = bool
  default     = true
}

variable "upload_to_aikido" {
  description = "Whether Terraform should call Aikido's public API to connect the GCP project."
  type        = bool
  default     = true
}

variable "aikido_api_token" {
  description = "Optional bearer token for Aikido's public API. If omitted, the module will request one using the client credentials flow."
  type        = string
  default     = null
  sensitive   = true
}

variable "aikido_client_id" {
  description = "Aikido OAuth client ID used to request an API access token."
  type        = string
  default     = null
  sensitive   = true
}

variable "aikido_client_secret" {
  description = "Aikido OAuth client secret used to request an API access token."
  type        = string
  default     = null
  sensitive   = true
}

variable "aikido_api_url" {
  description = "Aikido public API endpoint."
  type        = string
  default     = "https://app.aikido.dev/api/public/v1"
}

variable "aikido_oauth_token_url" {
  description = "Aikido OAuth token endpoint."
  type        = string
  default     = "https://app.aikido.dev/api/oauth/token"
}

variable "aikido_cloud_project_id" {
  description = "Project identifier sent to Aikido's API. Defaults to the same GCP project_id used by this module."
  type        = string
  default     = null
}
