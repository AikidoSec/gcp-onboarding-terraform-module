# gcp-onboarding-terraform-module

Terraform modules for connecting Google Cloud to Aikido using Workload Identity Federation.

Two modules are provided depending on your onboarding scope:

| Module                                 | Use when                              |
| -------------------------------------- | ------------------------------------- |
| [`modules/project`](./modules/project) | Connecting a single GCP project       |
| [`modules/org`](./modules/org)         | Connecting an entire GCP organization |

Both modules support:

- the base GCP cloud connection through Workload Identity Federation, with either direct access or access through service account impersonation (`access_mode`)
- optional Artifact Registry access
- optional GCP VM scanning IAM for the Aikido-managed scanner service account

The modules do **not** provision scanner-side infrastructure such as Cloud Build, Cloud Storage buckets, Artifact Registry repositories, or service account keys.

See the [changelog](./CHANGELOG.md) for release notes and upgrade instructions.

For the WIF-based cloud connection, both modules support multiple Aikido instances through `aikido_region`:

- `eu` (default, `app.aikido.dev`)
- `us` (`app.us.aikido.dev`)
- `me` (`app.me.aikido.dev`)
- `au` (`app.au.aikido.dev`)

Set `aikido_region` to the Aikido app region your account is on. If you use the default EU region (`app.aikido.dev`), you can omit it. This selects the default Aikido AWS principals used for CSPM and Artifact Registry access, and you can still override the raw AWS account ID and role ARNs explicitly if needed.

## Access modes

`access_mode` selects how Aikido's federated AWS principals get access:

- `direct` (default) — the read-only IAM roles are bound straight to the federated principals (`principalSet://…/attribute.aws_role/<arn>`).
- `impersonation` — the roles are bound to a service account instead, and the federated principals are granted `roles/iam.workloadIdentityUser` on it.

Use `impersonation` for organizations whose resources sit behind Google APIs that reject federated identities directly, such as App Engine. The module creates the service account by default; set `impersonation_service_account_email` to reuse an existing one.

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/project"

  project_id     = "my-gcp-project"
  project_number = "123456789"
  aikido_region  = "eu"

  access_mode = "impersonation"
}
```

## modules/project

Connects a single GCP project to Aikido. It:

- Enables the required Google APIs in the project
- Creates a Workload Identity Pool and AWS-backed provider in the project
- Grants Aikido read-only IAM access at the **project** level (`roles/viewer`, `roles/iam.securityReviewer`)
- Grants Artifact Registry read access for container scanning
- Optionally creates project-scoped custom roles and bindings for GCP VM scanning

### Usage

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/project"

  project_id     = "my-gcp-project"
  project_number = "123456789"
  aikido_region  = "eu"
}
```

### Optional VM scanning

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/project"

  project_id     = "my-gcp-project"
  project_number = "123456789"
  aikido_region  = "us"

  enable_vm_scanning                   = true
  gcp_vm_scanner_service_account_email = "aikido-vm-scanner@aikido-vm-scanning.iam.gserviceaccount.com"
}
```

When enabled, the module creates:

- `aikidoSecurityVmScannerRole`
- `aikidoSecurityVmScannerSnapshotDeleteRole`

and binds the provided Aikido-managed scanner service account at the project level. The delete role binding is conditioned so it only applies to snapshots whose name starts with `aik-snapshot-`.

## modules/org

Connects an entire GCP organization to Aikido. The Workload Identity Pool lives in a designated host project; IAM is granted at the **organization** level so all projects in the org are covered.

It:

- Enables the APIs required for Workload Identity Federation in the host project (`iam.googleapis.com`, `iamcredentials.googleapis.com`, `sts.googleapis.com`)
- Optionally enables the full set of Google APIs in the host project (`enable_host_project_services`)
- Creates a Workload Identity Pool and AWS-backed provider in the host project
- Grants Aikido read-only IAM access at the **organization** level (`roles/viewer`, `roles/iam.securityReviewer`, `roles/resourcemanager.folderViewer`)
- Optionally grants organization-level Artifact Registry read access for container scanning
- Optionally creates organization-scoped custom roles and bindings for GCP VM scanning

### Usage

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/org"

  organization_id = "1234567890"
  project_id      = "my-host-project"
  project_number  = "123456789"
  aikido_region   = "eu"
}
```

### Optional VM scanning

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/org"

  organization_id = "1234567890"
  project_id      = "my-host-project"
  project_number  = "123456789"
  aikido_region   = "us"

  enable_vm_scanning                   = true
  gcp_vm_scanner_service_account_email = "aikido-vm-scanner@aikido-vm-scanning.iam.gserviceaccount.com"
}
```

When enabled, the module creates:

- `aikidoSecurityVmScannerRole`
- `aikidoSecurityVmScannerSnapshotDeleteRole`

and binds the provided Aikido-managed scanner service account at the organization level. The delete role binding is conditioned so it only applies to Aikido-managed snapshots.

## After applying

Both modules output a `credential_config_json` value. Retrieve it and upload it to Aikido to complete the cloud connection:

```bash
terraform output -raw credential_config_json > aikido-gcp-credentials.json
```

If you enabled VM scanning, no bucket export setup or customer-side scanner service account key upload is required. The customer project only needs the IAM roles and bindings created by this module for the Aikido-managed scanner service account.
