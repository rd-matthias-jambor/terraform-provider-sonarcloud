terraform {
  required_providers {
    sonarcloud = {
      source = "rewe-digital/sonarcloud"
      version = "0.1.0"
    }
  }
}

provider "sonarcloud" {
  organization = var.organization
  token        = var.token
}

data "sonarcloud_organization_members" "users" {}

output "users" {
  value = data.sonarcloud_organization_members.users
}

data "sonarcloud_user_groups" "groups" {}

resource "sonarcloud_user_group" "example_group" {
  name        = "example_group"
  description = "Example group"
}

resource "sonarcloud_user_group_member" "example_member" {
  group = sonarcloud_user_group.example_group.name
  login = var.test_member_login
}

output "groups" {
  value = { for k, group in data.sonarcloud_user_groups.groups.groups : lower(group.name) => group }
}

resource "sonarcloud_user_group_permissions" "global" {
  group = sonarcloud_user_group.example_group.name
  permissions = ["scan"]
}

resource "sonarcloud_user_group_permissions" "project" {
  project = "${var.organization}_example"
  group = sonarcloud_user_group.example_group.name
  permissions = ["admin", "scan"]
}

resource "sonarcloud_user_token" "test_token" {
  login = var.test_token_login
  name  = "EXAMPLE_TOKEN"
}

output "token_value" {
  value = sonarcloud_user_token.test_token.token
}