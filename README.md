# HashiCorp Vault on GCP Cloud Run
This module creates a single node publicly accessible Vault server on Google Cloud Run with auto unseal using KMS and a Cloud Storage backend.

The original guide can be found at the following location:

[https://github.com/kelseyhightower/serverless-vault-with-cloud-run](https://github.com/kelseyhightower/serverless-vault-with-cloud-run)

## Example Usage

```hcl
module "vault" {
  source = "github.com/nicholasjackson/terraform-cloud-run-vault/"

  project_id            = "cloud-run-example"
  region                = "europe-west1"
  service_account_email = "myaccount@developer.gserviceaccount.com" 
}
```

## Variables
The following variables must be set to use this module:

* project_id - The Google Cloud project to deploy the Vault server to
* region - The Google Cloud project region
* service_account_email - The Google Cloud service account that is granted administer rights for Vault.

## Outputs

* vault_url - The address of the Vault server
* root_token - The root token generated when initializing Vault

## Required Services
The following APIs need to be enabled in your Google Cloud project to deploy this module:

* Secret Manager API
* Cloud Run
* Cloud KMS
* Storage
* IAM API
* Cloud Resource Manager
* Cloud SQL Admin API

## Required Permissions
To create the and configure the required resources the credentials used to run Terraform require the following IAM Roles:

* Project Editor
* Secret Manager Admin
* Cloud KMS Admin
* Cloud Run Admin
* Security Admin
* Service Account Token Creator (Vault Login)
* Service Account Admin (Vault Login)
