# vcnlivefire-v3

## Ansible

With this Ansible script we automate the following on the NSX Infrastructure side:

- Register compute manager
    - Register Site-B vCenter Server as a Compute Manager to Site-B NSX Manager
- Create IP Pools
    - Create the TEP IP pool
- Create edge uplink profile
    - Create the edge (transport node) uplink profile and specify the uplinks, name teaming policy settings, load balance settings and transport (TEP) VLAN settings
- Create host uplink profile
    - Create the host (transport node) uplink profile and specify the uplinks, name teaming policy settings, load balance settings and transport (TEP) VLAN settings
- Create transport zone
    - Create an VLAN transport zone
    - Create an overlay transport zone
- Create Transport Node Profiles
    - Create  (Host) Transport Node Profiles and specify the Uplink Profile, IP Pool and physical NICS
- Attach Transport node profile to collapsed cluster
    - Attach Transport node profile to collapsed cluster (Cluster-02) in Site-B
- Create VLAN Segments
    - create an VLAN segment for BGP Uplink #1
    - create an VLAN segment for BGP Uplink #2
- Create Edge Transport Nodes
    - Deploy two edge(s) (transport nodes) with the correct settings
- Create Edge (Transport Nodes) Cluster
    - Create Edge (Transport Nodes) Cluster and place the deployed edges inside the edge cluster

## Terraform

With this Terraform script we automate the following on the virtual NSX (underlay) network topology:

- Create VLAN Segments for Site B North/South Routing
    - create an VLAN segment for BGP Uplink #1
    - create an VLAN segment for BGP Uplink #2
- Create Site-B Tier-0 Gateway
    - create a tier-0 gateway
- Create Site-B Tier-0 Gateway Uplink Interfaces
    - create four uplink interfaces on the tier-0 gateway and assign IP adresses to the interfaces
- Site-B Tier-0 to ToR BGP Neighbor Configuration
    - Configure BGP peering between the tier-0 gateway and the Site-B Gateways
- Create Tier-1 Internal Gateway
    - create a tier-1 gateway
    - attach the tier-1 gateway to the tier-0 gateway
    - configure routing settings on the tier-1 gateway
- Create Tenant Segments
    - create an segment for web server VMs
    - create an segment for database server VMs
    - attach the segments to the tier-1 gateway
