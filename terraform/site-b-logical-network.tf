# Data Sources we need for reference later
data "nsxt_policy_transport_zone" "overlay-tz" {
   provider = nsxt.lm-site-b
   display_name = "overlay-tz"
}

data "nsxt_policy_transport_zone" "edge-vlan-tz" {
   provider = nsxt.lm-site-b
   display_name = "edge-vlan-tz"
}

# Edge Cluster
data "nsxt_policy_edge_cluster" "edge-cluster-02" {
   provider = nsxt.lm-site-b
   display_name = "edge-cluster-02"
}

# Edge Nodes
data "nsxt_policy_edge_node" "edge-01b" {
    provider = nsxt.lm-site-b
    edge_cluster_path   = data.nsxt_policy_edge_cluster.edge-cluster-02.path
    display_name        = "edge-01b"
}

data "nsxt_policy_edge_node" "edge-02b" {
    provider = nsxt.lm-site-b
    edge_cluster_path   = data.nsxt_policy_edge_cluster.edge-cluster-02.path
    display_name        = "edge-02b"
}

# Create VLAN Segments
resource "nsxt_policy_vlan_segment" "vlan-300" {
    provider = nsxt.lm-site-b
    display_name = "vlan-300"
    description = "Site B N/S VLAN Segment"
    transport_zone_path = data.nsxt_policy_transport_zone.edge-vlan-tz.path
    advanced_config {
         uplink_teaming_policy = "uplink-left"
    }
    vlan_ids = ["300"]
}

resource "nsxt_policy_vlan_segment" "vlan-400" {
    provider = nsxt.lm-site-b
    display_name = "vlan-400"
    description = "Site B N/S VLAN Segment"
    transport_zone_path = data.nsxt_policy_transport_zone.edge-vlan-tz.path
    advanced_config {
         uplink_teaming_policy = "uplink-right"
    }
    vlan_ids = ["400"]
}

# Create Site-B Tier-0 Gateway
resource "nsxt_policy_tier0_gateway" "t0-gateway" {
    provider = nsxt.lm-site-b
    display_name              = "t0-gateway"
    description               = "Site-B T0 Gateway"
    failover_mode             = "NON_PREEMPTIVE"
    default_rule_logging      = false
    enable_firewall           = false
    ha_mode                   = "ACTIVE_ACTIVE"
    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster-02.path

    bgp_config {
        ecmp            = true               
        local_as_num    = "65002"
        inter_sr_ibgp   = true
        multipath_relax = true
    }
}

# Create Site-B Tier-0 Gateway Uplink Interfaces
resource "nsxt_policy_tier0_gateway_interface" "vlan-300-edge-01b" {
    provider = nsxt.lm-site-b
    display_name        = "vlan-300-edge-01b"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge-01b.path
    gateway_path        = nsxt_policy_tier0_gateway.t0-gateway.path
    segment_path        = nsxt_policy_vlan_segment.vlan-300.path
    subnets             = ["192.168.253.130/25"]
    mtu                 = 1500
}

resource "nsxt_policy_tier0_gateway_interface" "vlan-300-edge-02b" {
    provider = nsxt.lm-site-b
    display_name        = "vlan-300-edge-02b"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge-02b.path
    gateway_path        = nsxt_policy_tier0_gateway.t0-gateway.path
    segment_path        = nsxt_policy_vlan_segment.vlan-300.path
    subnets             = ["192.168.253.131/25"]
    mtu                 = 1500
}

resource "nsxt_policy_tier0_gateway_interface" "vlan-400-edge-01b" {
    provider = nsxt.lm-site-b
    display_name        = "vlan-400-edge-01b"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge-01b.path
    gateway_path        = nsxt_policy_tier0_gateway.t0-gateway.path
    segment_path        = nsxt_policy_vlan_segment.vlan-400.path
    subnets             = ["192.168.254.130/25"]
    mtu                 = 1500
}

resource "nsxt_policy_tier0_gateway_interface" "vlan-400-edge-02b" {
    provider = nsxt.lm-site-b
    display_name        = "vlan-400-edge-02b"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge-02b.path
    gateway_path        = nsxt_policy_tier0_gateway.t0-gateway.path
    segment_path        = nsxt_policy_vlan_segment.vlan-400.path
    subnets             = ["192.168.254.131/25"]
    mtu                 = 1500
}

# Site-B Tier-0 to ToR BGP Neighbor Configuration
resource "nsxt_policy_bgp_neighbor" "ToR-A" {
    provider = nsxt.lm-site-b
    display_name        = "ToR-A"
    bgp_path            = nsxt_policy_tier0_gateway.t0-gateway.bgp_config.0.path
    neighbor_address    = "192.168.253.129"
#    source_addresses    = ["192.168.253.130", "192.168.253.131"]
    remote_as_num       = "65100"
}

resource "nsxt_policy_bgp_neighbor" "ToR-B" {
    provider = nsxt.lm-site-b
    display_name        = "ToR-B"
    bgp_path            = nsxt_policy_tier0_gateway.t0-gateway.bgp_config.0.path
    neighbor_address    = "192.168.254.129"
#    source_addresses    = ["192.168.254.130", "192.168.254.131"]
    remote_as_num       = "65100"
}

# Create Tier-1 Internal Gateway
resource "nsxt_policy_tier1_gateway" "t1-internal" {
    provider = nsxt.lm-site-b
    display_name              = "t1-internal"
    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge-cluster-02.path
    failover_mode             = "NON_PREEMPTIVE"
    default_rule_logging      = "false"
    enable_firewall           = "true"
    enable_standby_relocation = "false"
    tier0_path                = nsxt_policy_tier0_gateway.t0-gateway.path
    route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]

    tag {
        scope = "zone"
        tag   = "internal"
    }

    route_advertisement_rule {
        name                      = "Tier 1 Networks"
        action                    = "PERMIT"
        subnets                   = ["172.26.10.0/24","172.26.20.0/24"]
        prefix_operator           = "GE"
        route_advertisement_types = ["TIER1_CONNECTED"]
    }
}

# Create NSX-ALB Segments
resource "nsxt_policy_segment" "ov-se-mgmt" {
    provider = nsxt.lm-site-b
    display_name = "ov-se-mgmt"
    connectivity_path   = nsxt_policy_tier1_gateway.t1-internal.path
    transport_zone_path = data.nsxt_policy_transport_zone.overlay-tz.path
    
    subnet {
      cidr        = "172.26.90.1/24"
    }
}

resource "nsxt_policy_segment" "ov-lb-vip" {
    provider = nsxt.lm-site-b
    display_name = "ov-lb-vip"
    connectivity_path   = nsxt_policy_tier1_gateway.t1-internal.path
    transport_zone_path = data.nsxt_policy_transport_zone.overlay-tz.path
    
    subnet {
      cidr        = "172.26.100.1/24"
    }
}

