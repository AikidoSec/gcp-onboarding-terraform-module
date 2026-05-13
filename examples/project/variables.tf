variable "project_id" {
  description = "The Google Cloud project ID to connect to Aikido."
  type        = string
}

variable "project_number" {
  description = "The Google Cloud project number."
  type        = string
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
}

variable "vm_scanning_bucket_location" {
  description = "Location of the Cloud Storage bucket used for exported VM images."
  type        = string
  default     = null
}
