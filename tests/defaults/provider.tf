terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 3.13.0"
    }
  }
}

provider "gitlab" {
  token    = var.token
  base_url = var.base_url
  insecure = false
}
