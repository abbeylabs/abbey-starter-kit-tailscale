provider "abbey" {
  bearer_auth = var.abbey_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailnet
}
