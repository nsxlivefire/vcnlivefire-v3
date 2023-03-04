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
## NSX-T objects
data "nsxt_policy_transport_zone" "nsxt_mgmt_tz_name" {
  provider = nsxt.lm-site-b
  display_name = var.nsxt_cloud_mgmt_tz_name
}
data "nsxt_policy_transport_zone" "nsxt_data_tz_name" {
  provider = nsxt.lm-site-b
  display_name = var.nsxt_cloud_data_tz_name
}
data "nsxt_policy_tier0_gateway" "t0-gateway" {
  provider = nsxt.gm-site-a
  display_name = "t0-gateway-stretched"
}
resource "nsxt_policy_tier1_gateway" "nsxt_cloud_lr1" {
    provider = nsxt.lm-site-b
    display_name              = "t1-internal"
#    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster-02.path
#    failover_mode             = "NON_PREEMPTIVE"
#    default_rule_logging      = "false"
#    enable_firewall           = "true"
#    enable_standby_relocation = "false"
    tier0_path                = data.nsxt_policy_tier0_gateway.t0-gateway.path
    route_advertisement_types = ["TIER1_LB_VIP", "TIER1_CONNECTED"]

    tag {
        scope = "zone"
        tag   = "internal"
    }
}
resource "nsxt_policy_dhcp_relay" "dhcp_relay" {
  provider = nsxt.lm-site-b
  display_name     = "controlcenter-dhcp-relay"
  server_addresses = ["192.168.110.10"]
}

# Create NSX-ALB Segments
resource "nsxt_policy_segment" "ov-se-mgmt" {
    provider = nsxt.lm-site-b
    display_name = "ov-se-mgmt"
    connectivity_path   = nsxt_policy_tier1_gateway.nsxt_cloud_lr1.path
    transport_zone_path = data.nsxt_policy_transport_zone.nsxt_mgmt_tz_name.path
    subnet {
      cidr        = "172.26.90.1/24"
    }
    dhcp_config_path = nsxt_policy_dhcp_relay.dhcp_relay.path
}

resource "nsxt_policy_segment" "ov-lb-vip" {
    provider = nsxt.lm-site-b
    display_name = "ov-lb-vip"
    connectivity_path   = nsxt_policy_tier1_gateway.nsxt_cloud_lr1.path
    transport_zone_path = data.nsxt_policy_transport_zone.nsxt_data_tz_name.path
    subnet {
      cidr        = "172.26.100.1/24"
    }
    dhcp_config_path = nsxt_policy_dhcp_relay.dhcp_relay.path
}

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
          tier1_lr_id = nsxt_policy_tier1_gateway.nsxt_cloud_lr1.path
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
              tier1_lr_id = nsxt_policy_tier1_gateway.nsxt_cloud_lr1.path
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
#	se_name_prefix		= "cmp"
	max_se			= 4
	buffer_se		= 0
	se_deprovision_delay	= 1
        mem_reserve             = "false"
	vcenters {
           vcenter_ref = avi_vcenterserver.vcenter_server.id
           nsxt_clusters {
                cluster_ids = [data.vsphere_compute_cluster.cmp.id]
                include = true
          }
          nsxt_datastores {
                    ds_ids =  [data.vsphere_datastore.datastore.id]
                    include = false
                  }
       }
}

