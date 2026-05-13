locals {
  vm_scanning_principal_members = {
    for arn in var.aikido_vm_scanning_role_arns :
    arn => "${local.principal_prefix}/${arn}"
  }

  vm_scanning_role_bindings = var.enable_vm_scanning ? {
    for binding in flatten([
      for arn, member in local.vm_scanning_principal_members : [
        {
          key    = "${arn}:${var.vm_scanning_role_id}"
          member = member
          role   = google_project_iam_custom_role.aikido_vm_scanning[0].name
        }
      ]
    ]) : binding.key => binding
  } : {}

  vm_scanning_snapshot_delete_role_bindings = var.enable_vm_scanning ? {
    for binding in flatten([
      for arn, member in local.vm_scanning_principal_members : [
        {
          key    = "${arn}:${var.vm_scanning_snapshot_delete_role_id}"
          member = member
          role   = google_project_iam_custom_role.aikido_vm_scanning_snapshot_delete[0].name
        }
      ]
    ]) : binding.key => binding
  } : {}
}

resource "google_storage_bucket" "aikido_vm_scanning" {
  count = var.enable_vm_scanning ? 1 : 0

  project                     = var.project_id
  name                        = var.vm_scanning_bucket_name
  location                    = var.vm_scanning_bucket_location
  storage_class               = var.vm_scanning_bucket_storage_class
  force_destroy               = var.vm_scanning_bucket_force_destroy
  public_access_prevention    = var.vm_scanning_bucket_public_access_prevention
  uniform_bucket_level_access = var.vm_scanning_bucket_uniform_bucket_level_access
}

resource "google_project_iam_custom_role" "aikido_vm_scanning" {
  count = var.enable_vm_scanning ? 1 : 0

  role_id     = var.vm_scanning_role_id
  title       = "Aikido Security VM Scanner Role"
  description = "Permissions required for Aikido VM snapshot scanning"
  project     = var.project_id

  permissions = [
    "cloudbuild.builds.create",
    "cloudbuild.builds.get",
    "compute.disks.createSnapshot",
    "compute.disks.get",
    "compute.globalOperations.get",
    "compute.instanceGroups.get",
    "compute.instanceGroups.list",
    "compute.instances.list",
    "compute.snapshots.create",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.setLabels",
    "compute.zoneOperations.get",
    "iam.serviceAccounts.actAs",
  ]
}

resource "google_project_iam_custom_role" "aikido_vm_scanning_snapshot_delete" {
  count = var.enable_vm_scanning ? 1 : 0

  role_id     = var.vm_scanning_snapshot_delete_role_id
  title       = "Aikido Security VM Scanner Snapshot Delete Role"
  description = "Delete permissions for Aikido-managed VM snapshots"
  project     = var.project_id

  permissions = [
    "compute.snapshots.delete",
  ]
}

resource "google_project_iam_member" "aikido_vm_scanning_roles" {
  for_each = var.enable_vm_scanning ? local.vm_scanning_role_bindings : {}

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_project_iam_member" "aikido_vm_scanning_snapshot_delete_roles" {
  for_each = var.enable_vm_scanning ? local.vm_scanning_snapshot_delete_role_bindings : {}

  project = var.project_id
  role    = each.value.role
  member  = each.value.member

  condition {
    title       = "AikidoSnapshotDeleteOnly"
    description = "Restrict deletion to Aikido-managed snapshots."
    expression  = "resource.type == \"compute.googleapis.com/Snapshot\" && resource.name.startsWith(\"projects/${var.project_id}/global/snapshots/aik-snapshot-\")"
  }
}

resource "google_storage_bucket_iam_member" "aikido_vm_scanning_object_admin" {
  for_each = var.enable_vm_scanning ? local.vm_scanning_principal_members : {}

  bucket = google_storage_bucket.aikido_vm_scanning[0].name
  role   = "roles/storage.objectAdmin"
  member = each.value
}
