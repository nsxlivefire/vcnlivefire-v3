# Provider
terraform {
  required_providers {
    nsxt = {
      source  = "vmware/nsxt"
      version = "3.3.0"
    }
  }
}

# Access NSX-T provider - Site-B
provider "nsxt" {
  host                  = "nsxmgr-01b.corp.local"
  username              = "admin"
  password              = "VMware1!VMware1!"
  allow_unverified_ssl  = true
}

# NSX Services
data "nsxt_policy_service" "HTTPS" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "ICMPv4-ALL" {
  display_name = "ICMPv4-ALL"
}

data "nsxt_policy_service" "MySQL" {
  display_name = "MySQL"
}

data "nsxt_policy_service" "HTTP" {
  display_name = "HTTP"
}

# NSX Security Policy and Rules

resource "nsxt_policy_security_policy" "security-vds" {
  display_name     = "security-vds"
  category         = "Application"
  locked           = false
  stateful         = true
  tcp_strict       = false
  sequence_number  = 10

  rule {
    display_name       = "drupal-allow-http"
    action             = "ALLOW"
    services           = [data.nsxt_policy_service.HTTP.path]
    logged             = false
    destination_groups = [nsxt_policy_group.drupal-vm.path]
    scope              = [nsxt_policy_group.drupal-vm.path]
  }

  rule {
    display_name       = "drupal-mariadb-mysql"
    action             = "ALLOW"
    source_groups      = [nsxt_policy_group.drupal-vm.path]
    destination_groups = [nsxt_policy_group.mariadb-vm.path]
    logged             = false
    scope              = [nsxt_policy_group.drupal-vm.path, nsxt_policy_group.mariadb-vm.path]
  }

  rule {
    display_name       = "icmp-all-legacy"
    action             = "REJECT"
    services           = [data.nsxt_policy_service.ICMPv4-ALL.path]
    logged             = false
    destination_groups = [nsxt_policy_group.legacy-dvpg-group.path]
    scope              = [nsxt_policy_group.legacy-dvpg-group.path]
  }

  rule {
    display_name       = "deny-any"
    action             = "DROP"
    logged             = false
    scope              = [nsxt_policy_group.legacy-dvpg-group.path]
  }
}