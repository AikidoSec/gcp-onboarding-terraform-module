module "aikido_project" {
  source = "../../modules/project"

  project_id     = var.project_id
  project_number = var.project_number

  enable_vm_scanning                   = var.enable_vm_scanning
  gcp_vm_scanner_service_account_email = var.gcp_vm_scanner_service_account_email
}
