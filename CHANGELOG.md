# Changelog

## v1.0.1

### Fixed

- Fixed the organization module's VM scanner snapshot deletion condition. Fixes [#5](https://github.com/AikidoSec/gcp-onboarding-terraform-module/issues/5).

### Upgrading from v1.0.0

Update the module source reference to `?ref=v1.0.1`, run `terraform init -upgrade`, then review `terraform plan` and apply the change. For organization connections with `enable_vm_scanning = true`, this updates the existing snapshot deletion IAM binding. Updating the source reference alone does not change the installed IAM policy.

The project module's snapshot deletion condition is unchanged. No module inputs or outputs have changed.
