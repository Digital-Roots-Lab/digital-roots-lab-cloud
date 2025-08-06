terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_project" "project" {
  name        = "digital-roots-lab-cloud-dev"
  description = "Development enviroment for Digital Roots Lab."
  purpose     = "Organization Infrastructure"
  environment = "Development"
}

resource "digitalocean_container_registry" "registry" {
  name                   = "digital-roots-lab-dev"
  subscription_tier_slug = "starter"
}

variable "do_token" {
  description = "Digital Ocean Personal Access Token"
  type = string
}