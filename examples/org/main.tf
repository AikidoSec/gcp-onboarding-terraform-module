module "aikido_org" {
  source = "../../modules/org"

  organization_id = var.organization_id
  project_id      = var.host_project_id
  project_number  = var.host_project_number

  # Optionally enable artifact registry scanning
  # enable_artifact_registry_reader = true
}
