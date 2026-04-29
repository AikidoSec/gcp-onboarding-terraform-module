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
