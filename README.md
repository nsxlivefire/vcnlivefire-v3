# vcnlivefire-v3

## Terraform

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
