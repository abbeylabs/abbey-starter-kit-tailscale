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
      version = "0.2.4"
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

  policies = [
    { bundle = "github://organization/repo/policies" }
  ]

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
              src  = ["{{ .data.system.abbey.identities.tailscale.user }}"],
              dst  = ["*:*"],
          }],
        })
      }
    EOT
  }
}

resource "abbey_identity" "user_1" {
  abbey_account = "replace-me@example.com"
  source = "tailscale"
  metadata = jsonencode(
    {
      user = "replace-me@example.com"
    }
  )
}
