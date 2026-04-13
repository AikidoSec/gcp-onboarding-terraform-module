# gcp-onboarding-terraform-module

Reusable Terraform module for connecting a Google Cloud project and Google Container Registry to Aikido using Workload Identity Federation.

This module:

- enables the Google APIs required by Aikido's GCP integration
- creates a Workload Identity Pool and AWS-backed provider for Aikido
- grants Aikido's AWS roles read-only IAM and Artifact Registry access
- builds the Workload Identity Federation credential config in Terraform
- optionally exchanges Aikido OAuth client credentials for a bearer token and calls Aikido's public API to connect the GCP project


> [!NOTE]
> Prerequisite: create a REST API Aikido API Token with `cloud:write` and `container:write` scopes.

## What It Creates

### Google Cloud

- `google_project_service.required`
- `google_iam_workload_identity_pool.aikido`
- `google_iam_workload_identity_pool_provider.aikido_aws`
- `google_project_iam_member.aikido_project_roles`
- `google_project_iam_member.aikido_artifact_registry_reader`

### Aikido API

When `upload_to_aikido = true`, the module also:

1. calls `POST https://app.aikido.dev/api/oauth/token`
2. parses the returned `access_token`
3. calls `POST https://app.aikido.dev/api/public/v1/clouds/gcp`
4. uploads the stringified Workload Identity Federation config as `access_key`

## Usage

```hcl
module "aikido" {
  source = "../../../shared/modules/aikido"

  project_id     = var.project_id
  project_number = google_project.internal.number

  aikido_client_id     = var.aikido_client_id
  aikido_client_secret = var.aikido_client_secret

  # Optional overrides
  upload_to_aikido      = true
  aikido_cloud_project_id = var.project_id
}
```

## Inputs

### Required

| Name | Description |
| ---- | ----------- |
| `project_id` | Google Cloud project ID to connect |
| `project_number` | Google Cloud project number used in Workload Identity principal paths |

### Aikido Upload

| Name | Default | Description |
| ---- | ------- | ----------- |
| `upload_to_aikido` | `true` | Whether Terraform should call Aikido's API |
| `aikido_client_id` | `null` | OAuth client ID used to request an Aikido bearer token |
| `aikido_client_secret` | `null` | OAuth client secret used to request an Aikido bearer token |
| `aikido_api_token` | `null` | Optional pre-issued bearer token; if set, OAuth token exchange is skipped |
| `aikido_oauth_token_url` | `https://app.aikido.dev/api/oauth/token` | OAuth token endpoint |
| `aikido_api_url` | `https://app.aikido.dev/api/public/v1/clouds/gcp` | Aikido public API endpoint for connecting GCP |
| `aikido_cloud_project_id` | `null` | Project identifier sent to Aikido; defaults to `project_id` |

### Workload Identity Defaults

| Name | Default |
| ---- | ------- |
| `workload_identity_pool_location` | `global` |
| `workload_identity_pool_id` | `aikido-identity-pool` |
| `workload_identity_pool_display_name` | `Aikido Identity Pool` |
| `workload_identity_pool_description` | `Workload Identity Pool for Aikido Security integration` |
| `workload_identity_pool_provider_id` | `aikido-aws-provider` |
| `workload_identity_pool_provider_display_name` | `Aikido AWS Provider` |
| `workload_identity_pool_provider_description` | `Workload Identity Provider for Aikido Security's AWS account` |
| `aikido_aws_account_id` | `881830977366` |

### IAM Defaults

| Name | Default |
| ---- | ------- |
| `project_roles` | `roles/viewer`, `roles/iam.securityReviewer` |
| `aikido_project_role_arns` | `arn:aws:sts::881830977366:assumed-role/lambda-gcp-cloud-findings-role-1muvqxle` |
| `aikido_artifact_registry_role_arns` | `arn:aws:sts::881830977366:assumed-role/lambda-container-image-scanner-role-pb0qotst` |
| `enable_artifact_registry_reader` | `true` |
| `disable_services_on_destroy` | `false` |

## Outputs

| Name | Description |
| ---- | ----------- |
| `enabled_services` | Google APIs enabled by the module |
| `workload_identity_pool_name` | Full resource name of the Workload Identity Pool |
| `workload_identity_pool_provider_name` | Full resource name of the AWS Workload Identity Provider |
| `workload_identity_provider_audience` | Audience used in the generated external account config |
| `project_principal_members` | Principal members granted project-level roles |
| `artifact_registry_principal_members` | Principal members granted Artifact Registry reader |

## Generated Credential Config

The module generates the same kind of AWS external account config that you would normally create with:

```bash
gcloud iam workload-identity-pools create-cred-config \
  projects/{project_number}/locations/{location}/workloadIdentityPools/{pool_id}/providers/{provider_id} \
  --aws \
  --output-file=aikido-aws-provider.json
```

Terraform builds that JSON internally and sends it to Aikido as the stringified `access_key` request field.

The `regional_cred_verification_url` intentionally contains the literal `{region}` placeholder. That value is expected in the generated config and is resolved at runtime by Google's external account flow.

## Notes

- This module uses the `hashicorp/http` provider to make side-effecting API calls to Aikido.
- Because the upload is implemented via an HTTP data source, the request may be re-evaluated during future Terraform operations.
- Sensitive values such as the generated credential config and Aikido API responses are intentionally not exposed as outputs.
