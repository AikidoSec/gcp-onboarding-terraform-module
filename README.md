# gcp-onboarding-terraform-module

Terraform modules for connecting Google Cloud to Aikido using Workload Identity Federation.

Two modules are provided depending on your onboarding scope:

| Module | Use when |
|--------|----------|
| [`modules/project`](./modules/project) | Connecting a single GCP project |
| [`modules/org`](./modules/org) | Connecting an entire GCP organization |

> **Note**: GCP VM scanning support is currently available only in [`modules/project`](./modules/project).

## modules/project

Connects a single GCP project to Aikido. It:

- Enables the required Google APIs in the project
- Creates a Workload Identity Pool and AWS-backed provider in the project
- Grants Aikido read-only IAM access at the **project** level (`roles/viewer`, `roles/iam.securityReviewer`)
- Grants Artifact Registry read access for container scanning
- Optionally provisions the resources required for GCP VM scanning

### Usage

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/project"

  project_id     = "my-gcp-project"
  project_number = "123456789"

  # Optional: enable GCP VM scanning
  # enable_vm_scanning          = true
  # vm_scanning_bucket_name     = "my-aikido-vm-scanning-bucket"
  # vm_scanning_bucket_location = "europe-west1"
}
```

### Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `project_id` | yes | — | GCP project ID to connect |
| `project_number` | yes | — | GCP project number |
| `project_roles` | no | `roles/viewer`, `roles/iam.securityReviewer` | Project-level IAM roles granted to Aikido |
| `enable_vm_scanning` | no | `false` | Provision the resources required for GCP VM scanning |
| `vm_scanning_bucket_name` | no | `null` | Name of the Cloud Storage bucket used for exported VM images |
| `vm_scanning_bucket_location` | no | `null` | Location of the Cloud Storage bucket used for exported VM images |
| `workload_identity_pool_id` | no | `aikido-identity-pool` | |
| `workload_identity_pool_provider_id` | no | `aikido-aws-provider` | |
| `disable_services_on_destroy` | no | `false` | Disable APIs when the module is destroyed |

### Outputs

| Name | Description |
|------|-------------|
| `credential_config_json` | WIF credential config JSON to upload to Aikido |
| `vm_scanning_bucket_name` | Name of the VM scanning export bucket, if enabled |
| `vm_scanning_bucket_url` | URL of the VM scanning export bucket, if enabled |
| `workload_identity_pool_name` | Full resource name of the Workload Identity Pool |
| `workload_identity_pool_provider_name` | Full resource name of the AWS provider |

---

## modules/org

Connects an entire GCP organization to Aikido. The Workload Identity Pool lives in a designated host project; IAM is granted at the **organization** level so all projects in the org are covered.

It:

- Enables the APIs required for Workload Identity Federation in the host project (`iam.googleapis.com`, `iamcredentials.googleapis.com`, `sts.googleapis.com`)
- Optionally enables the full set of Google APIs in the host project (`enable_host_project_services`)
- Creates a Workload Identity Pool and AWS-backed provider in the host project
- Grants Aikido read-only IAM access at the **organization** level (`roles/viewer`, `roles/iam.securityReviewer`, `roles/resourcemanager.folderViewer`)
- Optionally grants organization-level Artifact Registry read access for container scanning

> **Note**: Folder include/exclude filtering is configured on the Aikido platform side, not via GCP IAM. The GCP resources provisioned by this module are the same regardless of which folders you choose to include or exclude in the Aikido UI.

### Usage

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/org"

  organization_id = "1234567890"
  project_id      = "my-host-project"
  project_number  = "123456789"
}
```

### Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `organization_id` | yes | — | GCP organization ID to connect |
| `project_id` | yes | — | Host project ID (holds the Workload Identity Pool) |
| `project_number` | yes | — | Host project number |
| `enable_artifact_registry_reader` | no | `false` | Grant org-level Artifact Registry read access for container scanning |
| `enable_host_project_services` | no | `false` | Enable the full set of Google APIs in the host project. The three APIs required for Workload Identity Federation (`iam.googleapis.com`, `iamcredentials.googleapis.com`, `sts.googleapis.com`) are always enabled regardless of this setting |
| `org_roles` | no | `roles/viewer`, `roles/iam.securityReviewer`, `roles/resourcemanager.folderViewer` | Org-level IAM roles granted to Aikido |
| `workload_identity_pool_id` | no | `aikido-identity-pool` | |
| `workload_identity_pool_provider_id` | no | `aikido-aws-provider` | |
| `disable_services_on_destroy` | no | `false` | Disable APIs when the module is destroyed |

### Outputs

| Name | Description |
|------|-------------|
| `credential_config_json` | WIF credential config JSON to upload to Aikido |
| `workload_identity_pool_name` | Full resource name of the Workload Identity Pool |
| `workload_identity_pool_provider_name` | Full resource name of the AWS provider |

---

## After applying

Both modules output a `credential_config_json` value. Retrieve it and upload it to Aikido to complete the connection:

```bash
terraform output -raw credential_config_json > aikido-gcp-credentials.json
```

Then upload `aikido-gcp-credentials.json` in the Aikido platform to finish the onboarding.

If you enabled VM scanning, also provide the bucket name output by the module when connecting GCP VM scanning in Aikido. The same `credential_config_json` output is used for both cloud scanning and VM scanning.
