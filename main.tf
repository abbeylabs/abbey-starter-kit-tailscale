locals {
  account_name = ""
  repo_name = ""

  project_path = "github://${local.account_name}/${local.repo_name}"
  policies_path = "${local.project_path}/policies"
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
    { bundle = local.policies_path }
  ]

  output = {
    location = "${local.project_path}/access.tf"
    append = <<-EOT
      resource "tailscale_acl" "sample_acl" {
        acl = jsonencode({
          acls : [
            {
              action = "accept",
              src  = ["{{ .user.email }}"],
              dst  = ["*:*"],
          }],
        })
      }
    EOT
  }
}
