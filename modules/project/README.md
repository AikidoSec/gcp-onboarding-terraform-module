# modules/project

Connects a single GCP project to Aikido using Workload Identity Federation.

It supports:

- the base GCP cloud connection, with direct or service-account-impersonation access
- optional Artifact Registry access
- optional project-scoped GCP VM scanning IAM for the Aikido-managed scanner service account

Set `aikido_region` to choose the default Aikido AWS principals used by the Workload Identity Provider:

- `eu` (default, `app.aikido.dev`)
- `us` (`app.us.aikido.dev`)
- `me` (`app.me.aikido.dev`)
- `au` (`app.au.aikido.dev`)

## Access modes

`access_mode` controls how the read-only IAM roles are granted:

| Mode               | What happens                                                                                                                                                   |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `direct` (default) | The roles are bound directly to Aikido's federated AWS principals (`principalSet://…/attribute.aws_role/<arn>`) at the project level.                          |
| `impersonation`    | The roles are bound to a service account at the project level, and Aikido's federated principals get `roles/iam.workloadIdentityUser` on that service account. |

Use `impersonation` when Aikido needs to read resources through Google APIs that do not accept federated identities directly — App Engine, for example.

```hcl
access_mode = "impersonation"
```

By default the module creates the service account in the project. To reuse an existing one (for example when an org policy blocks service account creation), set `impersonation_service_account_email` instead.

When `enable_vm_scanning = true`, the module:

- enables `compute.googleapis.com`
- creates the custom role `aikidoSecurityVmScannerRole`
- creates the custom role `aikidoSecurityVmScannerSnapshotDeleteRole`
- binds the provided managed scanner service account to both roles
- applies a condition on the delete role binding so it only matches snapshots named `aik-snapshot-*`
