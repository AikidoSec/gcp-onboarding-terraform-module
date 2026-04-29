output "credential_config_json" {
  description = "Workload Identity Federation credential config JSON to upload to Aikido."
  value       = module.aikido_org.credential_config_json
}

output "workload_identity_pool_name" {
  description = "Full resource name of the Aikido Workload Identity Pool."
  value       = module.aikido_org.workload_identity_pool_name
}

output "workload_identity_pool_provider_name" {
  description = "Full resource name of the Aikido AWS Workload Identity Provider."
  value       = module.aikido_org.workload_identity_pool_provider_name
}
