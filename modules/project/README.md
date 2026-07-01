# modules/project

Connects a single GCP project to Aikido using Workload Identity Federation.

It supports:

- the base GCP cloud connection
- optional Artifact Registry access
- optional project-scoped GCP VM scanning IAM for the Aikido-managed scanner service account

Set `aikido_region` to choose the default Aikido AWS principals used by the Workload Identity Provider:

- `eu` (default, `app.aikido.dev`)
- `us` (`app.us.aikido.dev`)
- `me` (`app.me.aikido.dev`)
- `au` (`app.au.aikido.dev`)

When `enable_vm_scanning = true`, the module:

- enables `compute.googleapis.com`
- creates the custom role `aikidoSecurityVmScannerRole`
- creates the custom role `aikidoSecurityVmScannerSnapshotDeleteRole`
- binds the provided managed scanner service account to both roles
- applies a condition on the delete role binding so it only matches snapshots named `aik-snapshot-*`

The module does not create any scanner-side buckets, Cloud Build jobs, service account keys, or Artifact Registry repositories.
