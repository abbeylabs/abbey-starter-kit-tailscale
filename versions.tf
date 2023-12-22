terraform {
  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "~> 0.2.6"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.7"
    }
  }
}
