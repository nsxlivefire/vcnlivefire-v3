data "nsxt_policy_transport_zone" "nsx-vlan-transportzone" {
  provider = nsxt.lm-site-b
  display_name = "nsx-vlan-transportzone"
}

data "nsxt_policy_tier1_gateway" "t1-internal" {
  provider = nsxt.lm-site-b
  display_name = "t1-internal"
}

resource "nsxt_policy_vlan_segment" "vlan-222" {
  provider = nsxt.lm-site-b
  display_name = "vlan-222"
  vlan_ids     = [222]
  transport_zone_path = data.nsxt_policy_transport_zone.nsx-vlan-transportzone.path
}

resource "nsxt_policy_tier1_gateway_interface" "si-vlan-222" {
  provider = nsxt.lm-site-b
  display_name           = "si-vlan-222"
  description            = "connection to vlan-222"
  gateway_path           = data.nsxt_policy_tier1_gateway.t1-internal.path
  segment_path           = nsxt_policy_vlan_segment.vlan-222.path
  subnets                = ["192.168.222.1/24"]
  mtu                    = 1500
}
