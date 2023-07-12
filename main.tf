terraform {
  backend "http" {
    address        = "https://api.abbey.io/terraform-http-backend"
    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.2"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.7"
    }
  }
}

provider "abbey" {
  # Configuration options
  bearer_auth = var.abbey_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailnet
}

resource "abbey_grant_kit" "tailscale_acl" {
  name = "Tailscale ACL"
  description = <<-EOT
    This resource represents a Tailscale ACL to access your Tailscale Network.

    This Grant Kit grants access and expires it automatically after 1 week.
  EOT

  workflow = {
    steps = [
      {
        reviewers = {
          # Replace with your Abbey login, typically your email used to sign up.
          one_of = ["replace-me@example.com"]
        }
      }
    ]
  }

  policies = {
    grant_if = [
      {
        # Optionally, you can build an OPA bundle and keep it in your repo.
        # `opa build -b policies/common -o policies/common.tar.gz`
        #
        # If you do, you can then specify `bundle` with:
        # bundle = "github://organization/repo/policies/common.tar.gz"
        #
        # Otherwise you can specify the directory. Abbey will build an
        # OPA bundle for you and recursively add all your policies.
        bundle = "github://organization/repo/policies"
      }
    ]
  }

  output = {
    # Replace with your own path pointing to where you want your access changes to manifest.
    # Path is an RFC 3986 URI, such as `github://{organization}/{repo}/path/to/file.tf`.
    location = "github://organization/repo/access.tf"
    append = <<-EOT
      resource "tailscale_acl" "sample_acl" {
        acl = jsonencode({
          acls : [
            {
              action = "accept",
              src  = ["{{ .data.system.abbey.secondary_identities.tailscale.user }}"],
              dst  = ["*:*"],
          }],
        })
      }
    EOT
  }
}

resource "abbey_identity" "user_1" {
  name = "replace-me"

  linked = jsonencode({
    abbey = [
      {
        type  = "AuthId"
        value = "replace-me@example.com"
      }
    ]

    tailscale = [
      {
        user = "replace-me@example.com"
      }
    ]
  })
}
