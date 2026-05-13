module "aikido_project" {
  source = "../../modules/project"

  project_id                  = var.project_id
  project_number              = var.project_number
  enable_vm_scanning          = var.enable_vm_scanning
  vm_scanning_bucket_name     = var.vm_scanning_bucket_name
  vm_scanning_bucket_location = var.vm_scanning_bucket_location
}
