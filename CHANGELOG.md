# Changelog

## v1.1.0

### Added

- Optional WIF service account impersonation in both modules, using a new or existing service account. Enabled cloud and container scanners share its permissions.
- `access_mode` and `impersonation_service_account_email` outputs, and configurable impersonation token lifetimes from 3600 to 43200 seconds.
- `org_principal_members` output for authoritative organization IAM bindings in both access modes.
- Host-project services option in the organization example and credential verification guidance.

### Changed

- Enable API Keys, Cloud Functions, and Cloud Run APIs in the project module and when host-project services are enabled in the organization module.
- Allow Google provider versions 7.x and 8.x in both modules and examples.

### Fixed

- Make IAM grants in both modules wait for the Workload Identity Pool, including impersonation grants.

## v1.0.1

### Fixed

- Fixed the organization module's VM scanner snapshot deletion condition. Fixes [#5](https://github.com/AikidoSec/gcp-onboarding-terraform-module/issues/5).

### Upgrading from v1.0.0

Update the module source reference to `?ref=v1.0.1`, run `terraform init -upgrade`, then review `terraform plan` and apply the change. For organization connections with `enable_vm_scanning = true`, this updates the existing snapshot deletion IAM binding. Updating the source reference alone does not change the installed IAM policy.

The project module's snapshot deletion condition is unchanged. No module inputs or outputs have changed.
