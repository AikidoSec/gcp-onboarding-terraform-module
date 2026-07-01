module "aikido_org" {
  source = "../../modules/org"

  organization_id = var.organization_id
  project_id      = var.host_project_id
  project_number  = var.host_project_number

  aikido_region                        = var.aikido_region
  enable_artifact_registry_reader      = var.enable_artifact_registry_reader
  enable_vm_scanning                   = var.enable_vm_scanning
  gcp_vm_scanner_service_account_email = var.gcp_vm_scanner_service_account_email

  vm_scanner_role_id        = var.vm_scanner_role_id
  vm_scanner_delete_role_id = var.vm_scanner_delete_role_id

  aikido_aws_account_id = var.aikido_aws_account_id

  aikido_project_role_arns = var.aikido_project_role_arns

  aikido_artifact_registry_role_arns = var.aikido_artifact_registry_role_arns

  workload_identity_pool_id           = var.workload_identity_pool_id
  workload_identity_pool_display_name = var.workload_identity_pool_display_name
}
