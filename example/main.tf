variable "project_id" {
  description = "Project ID in GCP"
  type        = string
}

variable "region" {
  description = "Region to deploy GCP resources"
  type        = string
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  pgp_key_nic = <<-EOF
    mQINBFeTRyABEACz9z++Cb4nbE7g+MoHTnbs1r/Q1sK1i8QSs+LBSyUKMsTdzyFwQWg1rtAl3huq
    FmhztMU4N80RzUqrgmMq9hQDVWFjKjEjSYGa/DRejNFCjHQBsD++XYYtO/scmxCy8k4vXl5YxDF1
    4jaBYQzB1JIoXZTZDaIoTmyE0SbwhdQ6cp1OZ2wNLuQGCrD38b+/mF1eKCt50MRYySogItuU1Io7
    Hb3bhUQlDgq6oZwMIgAe8gGLStlCfSAt1O651NsqGTODOFIKpkB+hXIfX81UMDVaIwVjnsRvrH8o
    +KqMcot4m1X+AOeBDABl+4yXidFvG9+CQIG+g6YzMJ/rP81plzhu2QwTMEFe/y5qTmvlDakh6Jl4
    25tQGvXfc0J04QcD1IGmC2N2Mi1mPeDQ0SQ/KWKK1WDpDUlykiWRE/uov5h/2tzy/CaUKL4uj1ET
    i41QaJ3i0+INNrtQNDpF1DHRp5AMyzO7KQoQxfpMCIx5E8czDKs87qEgNg2p6P2k8anuVFm+yTaW
    64SaTlfAyA3/dlTlVmiTPT5ZA6Ywrmzm8tAG5SYzKkrDrMrm7IAEHTKvSvQtQwdQeSdnDKZAH4ix
    DKBzbCiEllbs4yDvwBEgyOEr2pUVqf90xmifVBDFlTHg3D24nnn+opdlVkjBjZOPk9DBvviNTH3K
    6pAM3eJQE/G02QARAQABtCNOaWMgSmFja3NvbiA8amFja3Nvbi5uaWNAZ21haWwuY29tPokCVAQT
    AQoAPgIbAwULCQgHAwUVCgkICwUWAgMBAAIeAQIXgBYhBPVzKLEQlVc5PMxCQCzS5jX0QeXkBQJf
    WSGnBQkRK9wHAAoJECzS5jX0QeXkORYP/1SCnqxL50HWPLFsyAi2S4MIbyX0D4P0dvvoYID4BxtG
    wNiyZtqxDWnBOZddTm5eHMvA7a1BiVvrvgf1f9rXS5jnF8Q16y2OoaqdKHDqb8AvNftCaS6YiAqQ
    waB688GZrljxP96qMbKDtj3t7Iq4rwCNt16NNQa/DCWwHfaWcOnnCFTwgGPYvhsv5tyw0vskBL6g
    71F3W/kOpzGOSDAdERA2SQs2bVzwx218+ly5pyx0Gmob4vl3dIe4a8zqeLUnzPbdyg31nrqdBDQ6
    4dXt/Ze67hqoK4PMz3ovMCizy3hn1UuUxi6D02ACmk7IICPbBWouu0qPlzBvCVZVamX9fn+o60Jo
    I2wdLrLcHCOzAZ1DrVsNRiGxR4jicqV81Y5boqIeVuUtSGIXbfPccK0s+c1rrvZ5BtRtmtQT2UiF
    N8trB7fMasheqBaou4bWSz5Pk9ntRjKwhklQxlWEnlSpdeXfCHIotxo11JTrnmLozgCGxW3TJC83
    Bm9vffBHjou8JfPs/DVw2sj69f12GSPmWOCiid7ttorgn++Vqms2MrmGg9AJUks6LlOVpFUsv72P
    49CXOn801Z9ZzjAsfN1vsTQ9i616zw59zx9LcC/9fRqh8tryMzOwOcZVe3oK+/5ndLQH84JXbnhN
    8w4fX9ItZUIR/ZaeEENMztVnhGHUrX2iuQINBFeTRyABEAD2A17X6lOkZCPp2zI8V2qTEUheMSTP
    46RpbINYl08AB5jz/H8KRXStn4/vpjEgNsbafX5BDhagvr/Yf9BGLGTs8350kBW0ISCcVuXLuFWa
    b0OpBE8PqVpAfLfILLI26T+ejO7lZxiVrYGTIQGrbk5Da/VrXx5T+epGCeHB5rDWaMZuvvDohy11
    8UnvzbTIfdZw56V0X4UdJ7BMQWXamBpj0Mfa9N0nRWp8Hc3oKtH5RdAlvR+514/MWhl5mpRblr5/
    k4X4iYbvb2tEJC8bLa9hf4K9YOfUE1ExBvmLdhRkJi5UzNnAJXL39BUd4/PwLdVVYGqWp0U0+ZMz
    yygyhZ/jMaSw3uUBzQUcwGh/RNGuQyYsnKwpztR5uf47E9XkYkvf9rDGDV7c5ZKpF8Xdh/pGSnVy
    ngG0WXXTMyypMRG/JKKF5GSGXBvHiHv25Ki6XU6kFlmJ5TpJCMRbgtkLBkGaOacpBoer6lhUNWk2
    amyy/AyS7d1qz+dXl/pfxaG1AIigIcxoPAKH8WCeyF7pQr0KFDD+mcZ910z+LQ0eiqUCuz1M3Mfc
    3OBlnB/xHBs6u6ydiVrYQ3eNB8SHldnqRTv7l0L61DzMwgSqJEIchkDHtgeSTXMTz6Yr0wVwRAxT
    kRTRFg8+YtV4+zemXUGupAXjxNXShS/8p2R53hKL/djGhwARAQABiQI8BBgBCgAmAhsMFiEE9XMo
    sRCVVzk8zEJALNLmNfRB5eQFAl9ZIdcFCREr3DcACgkQLNLmNfRB5eR7iA//aeuiWgXf9BZQd/i6
    WGPCVdxSAWzD4+MlmwjAdSFi7Dhnmq/zuZVbsga5vIwNVyQ2ufQ8hlrETOtIftFgU9hAJJx32tk0
    9MFtdGJvqPiVw4JBQjPCQCoDytuLdYc2wgLUkjQ7l7Npf+qlmdUP4n6IjJZyP0K+jxxigRqVyw1n
    GijrEau38CY3vYKBSY7jUD9QQGlw7vd4HMXLZsMmEwQV/gHkC2tQBpzfN2Qp0W0Rwq5TkbxK0pY3
    GCw/1HFWEKvc6vLjrlwEEA+ghSgyKwNqtYKrOKEC9v/r5uMgQLVEMwDcN1mJRsy+x1LO9VoA821J
    mumExBpJdX+lcpLfbg4aBU8K7o+eO8RcX0UMsgiXVLeSOPYv85Y2y1KzODI7LGbfGeHDnS9+9jWy
    OwQ8XDobCffTTdkQRLePbB01jftPuqOny71MqP1g1BN5IuPNvj8Ec66dEMrqo5w7EZOe55RhZleA
    7Jhzt9nbHjoQJ23QUz/ITPUvLGNm42r2udzoAmbKCWo/5a8HPpxosOdKioR1mGqAdblwS+2HNOGQ
    am1R5WFZZV7FhpwLQj9jQilHAzK45AM+SUlYQOVyxEzXkCg2i2cpnpWV9oyGQpHsQ5l/tnFmEViy
    svopMjUw2braWabFgK63fHG6rRdxaDq36W9x7C/xqP593DWgf5D1Z+mDqRI=
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

output "vault_url" {
  value = module.vault.vault_url
}

output "root_token" {
  value = module.vault.root_token
}

output "recovery_keys" {
  value = module.vault.recovery_keys
}

output "recovery_keys_base64" {
  value = module.vault.recovery_keys_base64
}
