module "aikido_project" {
  source = "../../modules/project"

  project_id     = var.project_id
  project_number = var.project_number
}
