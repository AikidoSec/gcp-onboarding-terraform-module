# modules/org

Connects an entire GCP organization to Aikido using Workload Identity Federation.

The Workload Identity Pool lives in a designated host project; IAM is granted at the organization level so all projects in the organization are covered.

It supports:

- the base GCP organization connection, with direct or service-account-impersonation access
- optional Artifact Registry access
- optional organization-scoped GCP VM scanning IAM for the Aikido-managed scanner service account

Set `aikido_region` to choose the default Aikido AWS principals used by the Workload Identity Provider:

- `eu` (default, `app.aikido.dev`)
- `us` (`app.us.aikido.dev`)
- `me` (`app.me.aikido.dev`)
- `au` (`app.au.aikido.dev`)

## Access modes

`access_mode` controls how the read-only IAM roles are granted:

| Mode               | What happens                                                                                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `direct` (default) | The roles are bound directly to Aikido's federated AWS principals (`principalSet://…/attribute.aws_role/<arn>`) at the organization level.                          |
| `impersonation`    | The roles are bound to a service account, and the cloud-scanning and enabled container-scanning principals can impersonate it. |

Use `impersonation` when Aikido needs to read resources through Google APIs that do not accept federated identities directly, such as App Engine.

```hcl
access_mode = "impersonation"
```

By default the module creates the service account in the host project. To reuse an existing one (for example when an org policy blocks service account creation), set `impersonation_service_account_email` instead.

For a cross-project service account, enable `iamcredentials.googleapis.com` in its project first. The module only enables APIs in the host project.

With `enable_artifact_registry_reader = true`, automatic container onboarding reuses the same credential config. Both scanners share the service account's permissions, including cloud-scanning roles. Use `direct` mode to keep their IAM grants separate.

When `enable_vm_scanning = true`, the module:

- keeps the existing host-project WIF setup unchanged
- creates the custom role `aikidoSecurityVmScannerRole`
- creates the custom role `aikidoSecurityVmScannerSnapshotDeleteRole`
- binds the provided managed scanner service account to both roles at the organization level
- applies a condition on the delete role binding so it only matches Aikido-managed snapshots

## Credential verification

Enable `enable_host_project_services` for host-project scanning APIs and `enable_artifact_registry_reader` for container scanning access. Both default to `false`. See [credential verification](../../README.md#credential-verification) and the [organization example](../../examples/org).

## Authoritative IAM bindings

For roles managed by `google_organization_iam_binding`, exclude them from `org_roles` and add `org_principal_members` to your existing binding, preserving all other members. Do not manage the same role with both binding and member resources.

The output contains cloud-scanning federated principals in `direct` mode or the service account member in `impersonation` mode, even when `org_roles = []`.

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/org"

  organization_id = "1234567890"
  project_id      = "my-host-project"
  project_number  = "123456789"
  org_roles       = ["roles/viewer", "roles/resourcemanager.folderViewer"]
}

# Update your existing binding.
resource "google_organization_iam_binding" "security_reviewers" {
  org_id  = "1234567890"
  role    = "roles/iam.securityReviewer"
  members = concat(
    ["group:security@example.com"], # Keep all existing members.
    module.aikido.org_principal_members,
  )
}
```

When migrating existing module-managed grants, back up your state and use `terraform state rm` on only the affected `google_organization_iam_member.aikido_org_roles` instances before applying the configuration above. Removing them from `org_roles` alone revokes their grants. Review the plan to ensure the binding retains all members and no migrated member resources will be destroyed.
