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
  description = "Google APIs enabled by this module in the host project."
  value       = sort(tolist(local.enabled_services))
}

output "vm_scanner_member" {
  description = "Service account member granted VM scanning access when enable_vm_scanning is true."
  value       = local.vm_scanner_member
}

output "vm_scanner_role_name" {
  description = "Full resource name of the VM scanner custom role when enable_vm_scanning is true."
  value       = try(google_organization_iam_custom_role.vm_scanner[0].name, null)
}

output "vm_scanner_role_id" {
  description = "Role ID of the VM scanner custom role when enable_vm_scanning is true."
  value       = try(google_organization_iam_custom_role.vm_scanner[0].role_id, null)
}

output "vm_scanner_delete_role_name" {
  description = "Full resource name of the VM scanner delete custom role when enable_vm_scanning is true."
  value       = try(google_organization_iam_custom_role.vm_scanner_delete[0].name, null)
}

output "vm_scanner_delete_role_id" {
  description = "Role ID of the VM scanner delete custom role when enable_vm_scanning is true."
  value       = try(google_organization_iam_custom_role.vm_scanner_delete[0].role_id, null)
}
