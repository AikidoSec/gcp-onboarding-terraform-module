# gcp-onboarding-terraform-module

Terraform modules for connecting Google Cloud to Aikido using Workload Identity Federation.

Two modules are provided depending on your onboarding scope:

| Module | Use when |
|--------|----------|
| [`modules/project`](./modules/project) | Connecting a single GCP project |
| [`modules/org`](./modules/org) | Connecting an entire GCP organization |

## modules/project

Connects a single GCP project to Aikido. It:

- Enables the required Google APIs in the project
- Creates a Workload Identity Pool and AWS-backed provider in the project
- Grants Aikido read-only IAM access at the **project** level (`roles/viewer`, `roles/iam.securityReviewer`)
- Optionally grants Artifact Registry read access for container scanning

### Usage

```hcl
module "aikido" {
  source = "github.com/AikidoSec/gcp-onboarding-terraform-module//modules/project"

  project_id     = "my-gcp-project"
  project_number = "123456789"
}
```

### Inputs

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `project_id` | yes | — | GCP project ID to connect |
| `project_number` | yes | — | GCP project number |
| `enable_artifact_registry_reader` | no | `true` | Grant Artifact Registry read access for container scanning |
| `project_roles` | no | `roles/viewer`, `roles/iam.securityReviewer` | Project-level IAM roles granted to Aikido |
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

## modules/org

Connects an entire GCP organization to Aikido. The Workload Identity Pool lives in a designated host project; IAM is granted at the **organization** level so all projects in the org are covered.

It:

- Enables the required Google APIs in the host project
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
| `enable_artifact_registry_reader` | no | `true` | Grant org-level Artifact Registry read access for container scanning |
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
