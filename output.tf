output "enabled_services" {
  description = "Google APIs enabled for the Aikido integration."
  value       = sort(tolist(local.required_services))
}

output "workload_identity_pool_name" {
  description = "Full resource name of the Aikido Workload Identity Pool."
  value       = google_iam_workload_identity_pool.aikido.name
}

output "workload_identity_pool_provider_name" {
  description = "Full resource name of the Aikido AWS Workload Identity Provider."
  value       = google_iam_workload_identity_pool_provider.aikido_aws.name
}

output "workload_identity_provider_audience" {
  description = "Audience value to use when generating an external account credential config for Aikido."
  value       = local.workload_identity_provider_audience
}

output "project_principal_members" {
  description = "Principal members granted viewer and security reviewer access."
  value       = local.project_principal_members
}

output "artifact_registry_principal_members" {
  description = "Principal members granted Artifact Registry reader access."
  value       = local.artifact_registry_principal_members
}
