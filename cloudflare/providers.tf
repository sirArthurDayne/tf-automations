# config for terraform cloudflare experiment
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

cloudflare {
    api_token
    email
}
