# HashiCorp Vault on GCP Cloud Run
This module creates a single node publicly accessible Vault server on Google Cloud Run with auto unseal using KMS, and a Cloud Storage backend.

The original guide can be found at the following location:

[https://github.com/kelseyhightower/serverless-vault-with-cloud-run](https://github.com/kelseyhightower/serverless-vault-with-cloud-run)

## Simple Example

The following is a minimal example to create a Vault server in Cloud Run. Note: The root token and 
the recovery keys for this server will be exposed in the Terraofrm state.

```hcl
module "vault" {
  source = "../"

  region  = var.region
  project = var.project_id
  
  create_kms_keyring = false
  kms_keyring_name = "vault-unseal"
  kms_crypto_key_prefix = "unseal"

  admin_service_accounts  = ["1060272596826-compute@developer.gserviceaccount.com"]

  additional_admin_policy = <<-EOF
    # Manage database mounts
    path "database/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    
    # Enable permission to manage secrets
    path "secret/*"
    {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
  EOF

  cpu = "2.0"
  memory = "2048Mi"
}
```

## Example Showing Root Token Revocation and GPG Encryption of Recovery Keys

The following example creates a Vault server and automatically revokes the root token
generated in the init process, ensuring no secrets leak in the Terraform state.

Authentication to Vault can be completed using the following command:

```shell
vault login \
  -method=gcp \
  role="admin" \
  service_account=1060272596826-compute@developer.gserviceaccount.com \
  credentials=@cloud-security-day-b8c0e7ecafb4.json
```

The recovery keys that can be used to generate a new root token have also been pgp
encrypted. Decryption instructions can be found later in this read me.

```hcl
locals {
  pgp_key_nic = <<-EOF
    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
  EOF
}

module "vault" {
  source = "../"

  region  = var.region
  project = var.project_id

  admin_service_accounts = ["1060272596826-compute@developer.gserviceaccount.com"]

  create_kms_keyring = false
  recovery_pgp_keys  = [local.pgp_key_nic]

  revoke_root_token = true
}
```

## Note:
* It is not possible to delete KMS Keyrings, when running a `terraform destroy` if `create_kms_keyring` is set the keyring is only removed from the state.
* Due to the way Keyring keys are eventually destroyed, this module creates a unique key, the key is named with the given prefix and a random suffix. 

## Using GCP Authentication to Login to Vault

This module configures an Admin policy and the role `admin` that enables the configured service account to log into 
Vault using the GCP service account credentials. The following command

```shell
vault login \
  -method=gcp \
  role="admin" \
  service_account=1060272596826-compute@developer.gserviceaccount.com \
  credentials=@cloud-security-day-b8c0e7ecafb4.json
```

```shell
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                                 Value
---                                 -----
token                               hvs.CAESIOO53YAmOW7lGjyIo2IIiDRduF5khHD5f2hedLej7FNXGh4KHGh2cy5QaFFoc2FHY3l4MmM0ZEQwYldZcWtucE4
token_accessor                      eXtzTCGMaUxwtZOrrvKzEKrp
token_duration                      768h
token_renewable                     true
token_policies                      ["admin" "default"]
identity_policies                   []
policies                            ["admin" "default"]
token_meta_project_id               cloud-security-day
token_meta_role                     admin
token_meta_service_account_email    1060272596826-compute@developer.gserviceaccount.com
token_meta_service_account_id       116620822448188717316
```

## Fetching GPG keys from GPG Keyring

To list keys in your GPG keyring

```shell
gpg --list-keys
```

```shell
/home/nicj/.gnupg/pubring.kbx
-----------------------------
pub   rsa4096 2016-10-05 [SC]
      72ECF46A56B4AD39C907BBB71646B01B86E50310
uid           [ unknown] Yarn Packaging <yarn@dan.cx>
sub   rsa4096 2016-10-05 [E]

pub   rsa4096 2016-07-23 [SC] [expires: 2025-09-08]
      F57328B1109557393CCC42402CD2E635F441E5E4
uid           [ unknown] Nic Jackson <jackson.nic@gmail.com>
sub   rsa4096 2016-07-23 [E] [expires: 2025-09-08]
```

You can then export the chosen key 

```shell
gpg --output nic.gpg --export jackson.nic@gmail.com
```

Finally base64 encode this key to use with the module

```shell
cat nic.gpg | base64
```

## Decrypting GPG encoded recovery keys and generating a Root Token

First export the recovery key from the terraform output to a binary encoded document.

```shell
terraform output --json recovery_keys_base64 | jq -r '.[0]' | base64 -d > key.doc
```

Next use `gpg` to decrypt the key using your private key and save the key to a text file.

```shell
gpg --output key.txt --decrypt key.doc
```

To generate a new key you can use the `vault operator generate-root -init` command

```shell
vault operator generate-root -init
```

```shell
A One-Time-Password has been generated for you and is shown in the OTP field.
You will need this value to decode the resulting root token, so keep it safe.
Nonce         20466fcb-ca77-4e51-3390-c6aedc39536f
Started       true
Progress      0/1
Complete      false
OTP           kETLitEXbUFkCytAu0ZgMyEqmgLx
OTP Length    28
```

Next you need to call the `operator generate-root` command again using the key that you decrypted in the previous steps. 
This command will need to be run the same number of time specified in the `recovery_theshold` variable. You will need to use
a different key each time and this operation can be run from different machines.

```shell
cat key.txt | vault operator generate-root -nonce 20466fcb-ca77-4e51-3390-c6aedc39536f -
```

```shell
Nonce            99dfacd0-07d5-ec56-e22a-f66836873400
Started          true
Progress         1/1
Complete         true
Encoded Token    DgIlXVoWOQkqHBktLQMhOjgQKCo9XWVjYR0KVg
```

Once complete you can run the following command to decrypt the root token.

```shell
vault operator generate-root -decode=DgIlXVoWOQkqHBktLQMhOjgQKCo9XWVjYR0KVg -otp=kETLitEXbUFkCytAu0ZgMyEqmgLx
```

```shell
hvs.cGj9mrqEHtSYRxaSSl1W8oS1
```

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
