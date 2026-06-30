locals {
  base_required_services = toset([
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "storage-component.googleapis.com",
    "sts.googleapis.com",
  ])

  required_services = local.base_required_services

  principal_prefix = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.aws_role"

  project_principal_members = {
    for arn in var.aikido_project_role_arns :
    arn => "${local.principal_prefix}/${arn}"
  }

  artifact_registry_principal_members = {
    for arn in var.aikido_artifact_registry_role_arns :
    arn => "${local.principal_prefix}/${arn}"
  }

  project_role_bindings = {
    for binding in flatten([
      for arn, member in local.project_principal_members : [
        for role in var.project_roles : {
          key    = "${arn}:${role}"
          member = member
          role   = role
        }
      ]
    ]) : binding.key => binding
  }

  workload_identity_provider_audience = "//iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/providers/${var.workload_identity_pool_provider_id}"

  vm_scanner_member = var.enable_vm_scanning ? "serviceAccount:${trimspace(var.gcp_vm_scanner_service_account_email)}" : null

  vm_scanner_permissions = [
    "compute.instances.list",
    "compute.instanceGroups.get",
    "compute.instanceGroups.list",
    "compute.disks.createSnapshot",
    "compute.disks.get",
    "compute.snapshots.create",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.setLabels",
    "compute.snapshots.useReadOnly",
  ]

  vm_scanner_delete_condition_expression = "resource.type == \"compute.googleapis.com/Snapshot\" && resource.name.startsWith(\"projects/${var.project_id}/global/snapshots/aik-snapshot-\")"

  credential_config = {
    type               = "external_account"
    audience           = local.workload_identity_provider_audience
    subject_token_type = "urn:ietf:params:aws:token-type:aws4_request"
    token_url          = "https://sts.googleapis.com/v1/token"
    token_info_url     = "https://sts.googleapis.com/v1/introspect"
    universe_domain    = "googleapis.com"
    credential_source = {
      environment_id                 = "aws1"
      region_url                     = "http://169.254.169.254/latest/meta-data/placement/availability-zone"
      regional_cred_verification_url = "https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15"
      url                            = "http://169.254.169.254/latest/meta-data/iam/security-credentials"
    }
  }
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = var.disable_services_on_destroy
}

resource "google_iam_workload_identity_pool" "aikido" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = var.workload_identity_pool_display_name
  description               = var.workload_identity_pool_description

  depends_on = [
    google_project_service.required["iam.googleapis.com"],
    google_project_service.required["sts.googleapis.com"],
    google_project_service.required["iamcredentials.googleapis.com"],
  ]
}

resource "google_iam_workload_identity_pool_provider" "aikido_aws" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.aikido.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_pool_provider_id
  display_name                       = var.workload_identity_pool_provider_display_name
  description                        = var.workload_identity_pool_provider_description

  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.aws_role" = "assertion.arn.contains('assumed-role') ? assertion.arn.extract('{account_arn}assumed-role/') + 'assumed-role/' + assertion.arn.extract('assumed-role/{role_name}/') : assertion.arn"
  }

  aws {
    account_id = var.aikido_aws_account_id
  }
}

resource "google_project_iam_member" "aikido_project_roles" {
  for_each = local.project_role_bindings

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_project_iam_member" "aikido_artifact_registry_reader" {
  for_each = local.artifact_registry_principal_members

  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = each.value
}

resource "google_project_iam_custom_role" "vm_scanner" {
  count = var.enable_vm_scanning ? 1 : 0

  project     = var.project_id
  role_id     = var.vm_scanner_role_id
  title       = var.vm_scanner_role_title
  description = var.vm_scanner_role_description
  permissions = local.vm_scanner_permissions
  stage       = "GA"
}

resource "google_project_iam_custom_role" "vm_scanner_delete" {
  count = var.enable_vm_scanning ? 1 : 0

  project     = var.project_id
  role_id     = var.vm_scanner_delete_role_id
  title       = var.vm_scanner_delete_role_title
  description = var.vm_scanner_delete_role_description
  permissions = ["compute.snapshots.delete"]
  stage       = "GA"
}

resource "google_project_iam_member" "vm_scanner_role_binding" {
  count = var.enable_vm_scanning ? 1 : 0

  project = var.project_id
  role    = google_project_iam_custom_role.vm_scanner[0].name
  member  = local.vm_scanner_member
}

resource "google_project_iam_member" "vm_scanner_delete_role_binding" {
  count = var.enable_vm_scanning ? 1 : 0

  project = var.project_id
  role    = google_project_iam_custom_role.vm_scanner_delete[0].name
  member  = local.vm_scanner_member

  condition {
    title       = "AikidoSnapshotDeleteOnly"
    expression  = local.vm_scanner_delete_condition_expression
    description = "Allow deletion only for Aikido-managed snapshots."
  }
}
