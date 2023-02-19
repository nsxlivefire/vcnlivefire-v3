## vsphere objects
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}
data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "cmp" {
	name          = var.cluster
	datacenter_id = data.vsphere_datacenter.dc.id
}
#data "vsphere_compute_cluster" "mgmt" {
#	name          = "mgmt"
#	datacenter_id = data.vsphere_datacenter.dc.id
#}

## NSX-T objects
data "nsxt_policy_transport_zone" "nsxt_mgmt_tz_name" {
  provider = nsxt.lm-site-b
  display_name = var.nsxt_cloud_mgmt_tz_name
}
data "nsxt_policy_transport_zone" "nsxt_data_tz_name" {
  provider = nsxt.lm-site-b
  display_name = var.nsxt_cloud_data_tz_name
}
data "nsxt_policy_tier1_gateway" "nsxt_cloud_lr1" {
  provider = nsxt.lm-site-b
  display_name = var.nsxt_mgmt_lr_id
}

# Create NSX-ALB Segments
resource "nsxt_policy_segment" "ov-se-mgmt" {
    provider = nsxt.lm-site-b
    display_name = "ov-se-mgmt"
    connectivity_path   = nsxt_policy_tier1_gateway.t1-internal.path
    transport_zone_path = data.nsxt_policy_transport_zone.nsx-overlay-transportzone.path
    subnet {
      cidr        = "172.26.90.1/24"
    }
}

resource "nsxt_policy_segment" "ov-lb-vip" {
    provider = nsxt.lm-site-b
    display_name = "ov-lb-vip"
    connectivity_path   = nsxt_policy_tier1_gateway.t1-internal.path
    transport_zone_path = data.nsxt_policy_transport_zone.nsx-overlay-transportzone.path
    subnet {
      cidr        = "172.26.100.1/24"
    }
}

#
# Creating the resources
#

# Creating the content library in vCenter
resource "vsphere_content_library" "content_library" {
  name            = var.content_library_name
  storage_backing = [data.vsphere_datastore.datastore.id]
  description     = "Content library for AVI"
}

# Credential used to authenticate to NSX-T and vCenter

data "avi_cloudconnectoruser" "nsxt_cred" {
  name = var.nsxt_cloud_cred_name
}

# Credential used to authenticate to vCenter
data "avi_cloudconnectoruser" "vcsa_cred" {
  name = var.vcsa_cred_name
}

# Create NSX-T Cloud
resource "avi_cloud" "nsxt_cloud" {
  depends_on     = [data.avi_cloudconnectoruser.nsxt_cred]
  name = var.cloud_name
  tenant_ref = var.tenant
  vtype = "CLOUD_NSXT"
  dhcp_enabled = true
  obj_name_prefix = var.nsxt_cloud_prefix
  nsxt_configuration {
      nsxt_credentials_ref = data.avi_cloudconnectoruser.nsxt_cred.uuid
      nsxt_url = var.nsxt_cloud_url
      management_network_config {
        tz_type = var.nsxt_cloud_mgmt_tz_type
        transport_zone = data.nsxt_policy_transport_zone.nsxt_mgmt_tz_name.path
        overlay_segment {
          tier1_lr_id = data.nsxt_policy_tier1_gateway.nsxt_cloud_lr1.path
          segment_id  = nsxt_policy_segment.ov-se-mgmt.path
        }
      }
      data_network_config {
        tz_type = var.nsxt_cloud_data_tz_type
        transport_zone = data.nsxt_policy_transport_zone.nsxt_data_tz_name.path
        tier1_segment_config {
          segment_config_mode = "TIER1_SEGMENT_MANUAL"
          manual {
            tier1_lrs {
              tier1_lr_id = data.nsxt_policy_tier1_gateway.nsxt_cloud_lr1.path
              segment_id  = nsxt_policy_segment.ov-lb-vip.path
            }
          }
        }
      }
    }
}

# Associate vCenter & Content Library to NSX-T Cloud
resource "avi_vcenterserver" "vcenter_server" {
    name = var.nsxt_cloud_vcenter_name
    tenant_ref = var.tenant
    cloud_ref = avi_cloud.nsxt_cloud.id
    vcenter_url = var.vcenter_server
    content_lib {
      id = vsphere_content_library.content_library.id
    }
    vcenter_credentials_ref = data.avi_cloudconnectoruser.vcsa_cred.uuid
}

# This allows enough time to pass in order to do a avi_network
# avi_networks depends_on the time_sleep.wait_20_seconds
resource "time_sleep" "wait_20_seconds" {
  depends_on = [avi_cloud.nsxt_cloud]
  create_duration = "20s"
}

# update the service engine Default-Group to map to cmp cluster
resource "avi_serviceenginegroup" "cmp-se-group" {
    depends_on     = [time_sleep.wait_20_seconds]
	name			= "Default-Group"
	cloud_ref		= avi_cloud.nsxt_cloud.id
	tenant_ref		= var.tenant
	se_name_prefix		= "cmp"
	max_se			= 4
	buffer_se		= 0
	se_deprovision_delay	= 1
        mem_reserve             = "false"
#	vcenters {
#		vcenter_ref = avi_vcenterserver.vcenter_server.id
#    nsxt_clusters {
#      cluster_ids = [data.vsphere_compute_cluster.cmp.id]
#      include = true
#    }
#	}
}

# configure networks
resource "avi_network" "ov-se-mgmt" {
    depends_on     = [time_sleep.wait_20_seconds]
    name = "ov-se-mgmt"
    tenant_ref		= var.tenant
    cloud_ref               = avi_cloud.nsxt_cloud.id
    dhcp_enabled = "false"
    ip6_autocfg_enabled = "false"
    configured_subnets {
		prefix {
			ip_addr {
				addr = "172.26.90.0"
				type = "V4"
			}
			mask = 24
		}
		static_ip_ranges {
			type  = "STATIC_IPS_FOR_VIP"
			range {
				begin {
					addr = "172.26.90.100"
					type = "V4"
				}
				end {
					addr = "172.26.90.120"
					type = "V4"
				}
			}
		}
	}
}

#data "avi_vrfcontext" "t1_internal" {
#    depends_on     = [time_sleep.wait_20_seconds]
#    name = "t1-internal"
#    cloud_ref               = avi_cloud.nsxt_cloud.id
#}

resource "avi_vrfcontext" "t1_internal" {
    depends_on     = [time_sleep.wait_20_seconds]
    name = "t1-internal"
    cloud_ref               = avi_cloud.nsxt_cloud.id
    static_routes {
		prefix {
		ip_addr {
				addr = "172.16.10.0"
				type = "V4"
			}
		mask = 24
		}
                next_hop {
			type  = "V4"
			addr = "172.26.100.1"
			}
                route_id = "1"
    } 
}

resource "avi_network" "ov-lb-vip" {
    depends_on     = [time_sleep.wait_20_seconds]
    name = "ov-lb-vip"
    tenant_ref		= var.tenant
    cloud_ref               = avi_cloud.nsxt_cloud.id
    dhcp_enabled = "false"
    ip6_autocfg_enabled = "false"
    vrf_context_ref     = avi_vrfcontext.t1_internal.id
    configured_subnets {
		prefix {
			ip_addr {
				addr = "172.26.100.0"
				type = "V4"
			}
			mask = 24
		}
		static_ip_ranges {
			type  = "STATIC_IPS_FOR_VIP"
			range {
				begin {
					addr = "172.26.100.100"
					type = "V4"
				}
				end {
					addr = "172.26.100.120"
					type = "V4"
				}
			}
		}
       }
}

