terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 7.27"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }
  }
}

locals {
  required_services = toset([
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "storage-component.googleapis.com",
    "sts.googleapis.com",
  ])

  project_principal_members = {
    for role_arn in var.aikido_project_role_arns :
    role_arn => "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/${var.workload_identity_pool_location}/workloadIdentityPools/${google_iam_workload_identity_pool.aikido.workload_identity_pool_id}/attribute.aws_role/${role_arn}"
  }

  artifact_registry_principal_members = {
    for role_arn in var.aikido_artifact_registry_role_arns :
    role_arn => "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/${var.workload_identity_pool_location}/workloadIdentityPools/${google_iam_workload_identity_pool.aikido.workload_identity_pool_id}/attribute.aws_role/${role_arn}"
  }

  project_role_bindings = {
    for binding in flatten([
      for role_arn, member in local.project_principal_members : [
        for role in var.project_roles : {
          key    = "${role_arn} ${role}"
          member = member
          role   = role
        }
      ]
      ]) : binding.key => {
      member = binding.member
      role   = binding.role
    }
  }

  workload_identity_provider_audience = "//iam.googleapis.com/projects/${var.project_number}/locations/${var.workload_identity_pool_location}/workloadIdentityPools/${var.workload_identity_pool_id}/providers/${var.workload_identity_pool_provider_id}"

  credential_config = {
    audience = local.workload_identity_provider_audience
    credential_source = {
      environment_id                 = "aws1"
      region_url                     = "http://169.254.169.254/latest/meta-data/placement/availability-zone"
      regional_cred_verification_url = "https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15"
      url                            = "http://169.254.169.254/latest/meta-data/iam/security-credentials"
    }
    subject_token_type = "urn:ietf:params:aws:token-type:aws4_request"
    token_info_url     = "https://sts.googleapis.com/v1/introspect"
    token_url          = "https://sts.googleapis.com/v1/token"
    type               = "external_account"
    universe_domain    = "googleapis.com"
  }

  credential_config_json = jsonencode(local.credential_config)
  aikido_request_body = jsonencode({
    access_key  = local.credential_config_json
    project_id  = coalesce(var.aikido_cloud_project_id, var.project_id)
    environment = "production"
    name        = "GCP Cloud environment"
  })

  aikido_gcr_request_body = jsonencode({
    service_account_key  = local.credential_config_json
    project_id  = coalesce(var.aikido_cloud_project_id, var.project_id)
  })

  should_request_aikido_token = var.upload_to_aikido && var.aikido_api_token == null
  aikido_basic_auth_header    = local.should_request_aikido_token ? "Basic ${base64encode("${var.aikido_client_id}:${var.aikido_client_secret}")}" : null
}

data "http" "aikido_oauth_token" {
  count = local.should_request_aikido_token ? 1 : 0

  url    = var.aikido_oauth_token_url
  method = "POST"

  request_headers = {
    Authorization = local.aikido_basic_auth_header
    accept        = "application/json"
    content-type  = "application/json"
  }

  request_body = jsonencode({
    grant_type = "client_credentials"
  })
}

locals {
  aikido_access_token = coalesce(
    var.aikido_api_token,
    try(jsondecode(data.http.aikido_oauth_token[0].response_body).access_token, null),
  )
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = var.disable_services_on_destroy
}

resource "google_iam_workload_identity_pool" "aikido" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = var.workload_identity_pool_display_name
  description               = var.workload_identity_pool_description
  disabled                  = false

  depends_on = [
    google_project_service.required["iam.googleapis.com"],
    google_project_service.required["sts.googleapis.com"],
    google_project_service.required["iamcredentials.googleapis.com"],
  ]
}

resource "google_iam_workload_identity_pool_provider" "aikido_aws" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.aikido.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_pool_provider_id
  display_name                       = var.workload_identity_pool_provider_display_name
  description                        = var.workload_identity_pool_provider_description
  disabled                           = false

  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.aws_role" = "assertion.arn.contains('assumed-role') ? assertion.arn.extract('{account_arn}assumed-role/') + 'assumed-role/' + assertion.arn.extract('assumed-role/{role_name}/') : assertion.arn"
  }

  aws {
    account_id = var.aikido_aws_account_id
  }
}

resource "google_project_iam_member" "aikido_project_roles" {
  for_each = local.project_role_bindings

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_project_iam_member" "aikido_artifact_registry_reader" {
  for_each = var.enable_artifact_registry_reader ? local.artifact_registry_principal_members : {}

  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = each.value
}

data "http" "aikido_connect_gcp" {
  count = var.upload_to_aikido ? 1 : 0

  url    = "${var.aikido_api_url}/clouds/gcp"
  method = "POST"

  request_headers = {
    Authorization = "Bearer ${local.aikido_access_token}"
    Content-Type  = "application/json"
  }

  request_body = local.aikido_request_body

  depends_on = [
    google_iam_workload_identity_pool.aikido,
    google_iam_workload_identity_pool_provider.aikido_aws,
    google_project_iam_member.aikido_project_roles,
    google_project_iam_member.aikido_artifact_registry_reader,
  ]
}

data "http" "aikido_connect_gcr" {
    count = var.upload_to_aikido ? 1 : 0

    url    = "${var.aikido_api_url}/containers/registries/gcp-artifact-registry"
    method = "POST"

    request_headers = {
        Authorization = "Bearer ${local.aikido_access_token}"
        Content-Type  = "application/json"
    }

    request_body = local.aikido_gcr_request_body

    depends_on = [
        data.http.aikido_connect_gcp,
        google_iam_workload_identity_pool.aikido,
        google_iam_workload_identity_pool_provider.aikido_aws,
        google_project_iam_member.aikido_project_roles,
        google_project_iam_member.aikido_artifact_registry_reader,
    ]
}
