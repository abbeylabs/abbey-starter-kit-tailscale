variable "abbey_token" {
  type = string
  sensitive = true
  description = "Abbey API Token"
}

variable "tailscale_api_key" {
  type = string
  sensitive = "true"
  description = "Tailscale API Key"
}

variable "tailnet" {
  type = string
  sensitive = "true"
  description = "Tailnet/Organization name"
}
