module "aikido_org" {
  source = "../../modules/org"

  organization_id = var.organization_id
  project_id      = var.host_project_id
  project_number  = var.host_project_number

  enable_artifact_registry_reader      = var.enable_artifact_registry_reader
  enable_vm_scanning                   = var.enable_vm_scanning
  gcp_vm_scanner_service_account_email = var.gcp_vm_scanner_service_account_email
}
