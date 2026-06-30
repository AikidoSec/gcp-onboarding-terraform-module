# gcp-onboarding-terraform-module

Terraform modules for connecting Google Cloud to Aikido using Workload Identity Federation.

Two modules are provided depending on your onboarding scope:

| Module | Use when |
|--------|----------|
| [`modules/project`](./modules/project) | Connecting a single GCP project |
| [`modules/org`](./modules/org) | Connecting an entire GCP organization |

Both modules support:
- the base GCP cloud connection through Workload Identity Federation
- optional Artifact Registry access
- optional GCP VM scanning IAM for the Aikido-managed scanner service account

The modules do **not** provision scanner-side infrastructure such as Cloud Build, Cloud Storage buckets, Artifact Registry repositories, or service account keys.

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
}
```

### Optional VM scanning

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/project"

  project_id     = "my-gcp-project"
  project_number = "123456789"

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
}
```

### Optional VM scanning

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/org"

  organization_id = "1234567890"
  project_id      = "my-host-project"
  project_number  = "123456789"

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
