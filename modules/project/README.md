# modules/project

Connects a single GCP project to Aikido using Workload Identity Federation.

<!-- BEGIN_TF_DOCS -->


## Resources

| Name | Type |
| ---- | ---- |
| [google_iam_workload_identity_pool.aikido](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.aikido_aws](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_member.aikido_artifact_registry_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.aikido_project_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aikido_artifact_registry_role_arns"></a> [aikido\_artifact\_registry\_role\_arns](#input\_aikido\_artifact\_registry\_role\_arns) | Aikido AWS role ARNs that should receive Artifact Registry read access for container scanning. | `set(string)` | <pre>[<br/>  "arn:aws:sts::881830977366:assumed-role/lambda-container-image-scanner-role-pb0qotst"<br/>]</pre> | no |
| <a name="input_aikido_aws_account_id"></a> [aikido\_aws\_account\_id](#input\_aikido\_aws\_account\_id) | Aikido's AWS account ID used to scope the Workload Identity Provider. | `string` | `"881830977366"` | no |
| <a name="input_aikido_project_role_arns"></a> [aikido\_project\_role\_arns](#input\_aikido\_project\_role\_arns) | Aikido AWS role ARNs that should receive project-level read access for cloud scanning. | `set(string)` | <pre>[<br/>  "arn:aws:sts::881830977366:assumed-role/lambda-gcp-cloud-findings-role-1muvqxle"<br/>]</pre> | no |
| <a name="input_disable_services_on_destroy"></a> [disable\_services\_on\_destroy](#input\_disable\_services\_on\_destroy) | Whether to disable the Google APIs enabled by this module when it is destroyed. | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID to connect to Aikido. | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | The Google Cloud project number, used in Workload Identity principal paths. | `string` | n/a | yes |
| <a name="input_project_roles"></a> [project\_roles](#input\_project\_roles) | Project-level IAM roles granted to Aikido's cloud scanning role. | `set(string)` | <pre>[<br/>  "roles/viewer",<br/>  "roles/iam.securityReviewer"<br/>]</pre> | no |
| <a name="input_workload_identity_pool_description"></a> [workload\_identity\_pool\_description](#input\_workload\_identity\_pool\_description) | Description for the Aikido Workload Identity Pool. | `string` | `"Workload Identity Pool for Aikido Security integration"` | no |
| <a name="input_workload_identity_pool_display_name"></a> [workload\_identity\_pool\_display\_name](#input\_workload\_identity\_pool\_display\_name) | Display name for the Aikido Workload Identity Pool. | `string` | `"Aikido Identity Pool"` | no |
| <a name="input_workload_identity_pool_id"></a> [workload\_identity\_pool\_id](#input\_workload\_identity\_pool\_id) | ID for the Aikido Workload Identity Pool. | `string` | `"aikido-identity-pool"` | no |
| <a name="input_workload_identity_pool_provider_description"></a> [workload\_identity\_pool\_provider\_description](#input\_workload\_identity\_pool\_provider\_description) | Description for the Aikido AWS Workload Identity Provider. | `string` | `"Workload Identity Provider for Aikido Security's AWS account"` | no |
| <a name="input_workload_identity_pool_provider_display_name"></a> [workload\_identity\_pool\_provider\_display\_name](#input\_workload\_identity\_pool\_provider\_display\_name) | Display name for the Aikido AWS Workload Identity Provider. | `string` | `"Aikido AWS Provider"` | no |
| <a name="input_workload_identity_pool_provider_id"></a> [workload\_identity\_pool\_provider\_id](#input\_workload\_identity\_pool\_provider\_id) | ID for the Aikido AWS Workload Identity Provider. | `string` | `"aikido-aws-provider"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_credential_config_json"></a> [credential\_config\_json](#output\_credential\_config\_json) | Workload Identity Federation credential config JSON to upload to Aikido. |
| <a name="output_enabled_services"></a> [enabled\_services](#output\_enabled\_services) | Google APIs enabled by this module. |
| <a name="output_workload_identity_pool_name"></a> [workload\_identity\_pool\_name](#output\_workload\_identity\_pool\_name) | Full resource name of the Aikido Workload Identity Pool. |
| <a name="output_workload_identity_pool_provider_name"></a> [workload\_identity\_pool\_provider\_name](#output\_workload\_identity\_pool\_provider\_name) | Full resource name of the Aikido AWS Workload Identity Provider. |
| <a name="output_workload_identity_provider_audience"></a> [workload\_identity\_provider\_audience](#output\_workload\_identity\_provider\_audience) | Audience value used in the external account credential config. |
<!-- END_TF_DOCS -->
