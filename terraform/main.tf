terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "3.3.0"
      configuration_aliases = [ nsxt.alternate ]
    }
    avi = {
      source  = "vmware/avi"
      version = "22.1.3"
    }
  }
}

# Site-A NSX Manager provider setup
provider "nsxt" {
  host                  = var.nsxmgr-01a_ip
  username              = var.nsx_username
  password              = var.nsx_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

# Site-B NSX Manager provider setup
provider "nsxt" {
  host                  = var.nsxmgr-01b_ip
  username              = var.nsx_username
  password              = var.nsx_password
  alias = "lm-site-b"
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

# Global NSX Manager provider setup
provider "nsxt" {
  host           = var.nsxgmgr-01a_ip
  username       = var.nsx_username
  password       = var.nsx_password
  alias = "gm-site-a"
  global_manager = true
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
}

# Avi provider setup
provider "avi" {
        avi_controller          = var.avi_controller
        avi_username            = var.avi_username
        avi_password            = var.avi_password
        avi_version             = var.avi_version
        avi_tenant              = "admin"
}

# vCenter provider
provider "vsphere" {
        user                    = var.vcenter_username
        password                = var.vcenter_password
        vsphere_server          = var.vcenter_server
        allow_unverified_ssl    = true
}
