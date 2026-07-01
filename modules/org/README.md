# modules/org

Connects an entire GCP organization to Aikido using Workload Identity Federation.

The Workload Identity Pool lives in a designated host project; IAM is granted at the organization level so all projects in the organization are covered.

It supports:

- the base GCP organization connection
- optional Artifact Registry access
- optional organization-scoped GCP VM scanning IAM for the Aikido-managed scanner service account

Set `aikido_region` to choose the default Aikido AWS principals used by the Workload Identity Provider:

- `eu` (default, `app.aikido.dev`)
- `us` (`app.us.aikido.dev`)
- `me` (`app.me.aikido.dev`)
- `au` (`app.au.aikido.dev`)

When `enable_vm_scanning = true`, the module:

- keeps the existing host-project WIF setup unchanged
- creates the custom role `aikidoSecurityVmScannerRole`
- creates the custom role `aikidoSecurityVmScannerSnapshotDeleteRole`
- binds the provided managed scanner service account to both roles at the organization level
- applies a condition on the delete role binding so it only matches Aikido-managed snapshots
