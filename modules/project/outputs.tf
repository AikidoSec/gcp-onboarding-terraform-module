output "workload_identity_pool_name" {
  description = "Full resource name of the Aikido Workload Identity Pool."
  value       = google_iam_workload_identity_pool.aikido.name
}

output "workload_identity_pool_provider_name" {
  description = "Full resource name of the Aikido AWS Workload Identity Provider."
  value       = google_iam_workload_identity_pool_provider.aikido_aws.name
}

output "workload_identity_provider_audience" {
  description = "Audience value used in the external account credential config."
  value       = local.workload_identity_provider_audience
}

output "credential_config_json" {
  description = "Workload Identity Federation credential config JSON to upload to Aikido."
  value       = jsonencode(local.credential_config)
}

output "enabled_services" {
  description = "Google APIs enabled by this module."
  value       = sort(tolist(local.required_services))
}

output "vm_scanning_bucket_name" {
  description = "Name of the Cloud Storage bucket used for VM scanning exports."
  value       = try(google_storage_bucket.aikido_vm_scanning[0].name, null)
}

output "vm_scanning_bucket_url" {
  description = "URL of the Cloud Storage bucket used for VM scanning exports."
  value       = try(google_storage_bucket.aikido_vm_scanning[0].url, null)
}
