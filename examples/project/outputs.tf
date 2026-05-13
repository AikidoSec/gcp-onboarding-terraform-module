output "credential_config_json" {
  description = "Workload Identity Federation credential config JSON to upload to Aikido."
  value       = module.aikido_project.credential_config_json
}

output "workload_identity_pool_name" {
  description = "Full resource name of the Aikido Workload Identity Pool."
  value       = module.aikido_project.workload_identity_pool_name
}

output "workload_identity_pool_provider_name" {
  description = "Full resource name of the Aikido AWS Workload Identity Provider."
  value       = module.aikido_project.workload_identity_pool_provider_name
}

output "vm_scanning_bucket_name" {
  description = "Name of the Cloud Storage bucket used for VM scanning exports."
  value       = module.aikido_project.vm_scanning_bucket_name
}
