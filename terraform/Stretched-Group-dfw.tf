#Create Global Group for 2-tier webapp for grouping Web and DB VMs in seperate groups

resource "nsxt_policy_group" "g-web-stretched" {
  provider = nsxt.global_manager
  display_name = "g-web-stretched"
  description  = "Stretched Global web group"
  nsx_id = "g-web-stretched"
  tag {
      scope = "webapp"
      tag = "web"
       }


  criteria {
   condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value       = "webapp|web"
     }
           }
}
resource "nsxt_policy_group" "g-db-stretched" {
  provider = nsxt.global_manager
  display_name = "g-db-stretched"
  description  = "Stretched Global db group"
  nsx_id = "g-db-stretched"
  tag {
      scope = "webapp"
      tag = "db"
       }


  criteria {
   condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value       = "webapp|db"
     }
           }
}

# Create 2-Tier webapp Global DFW rule

data "nsxt_policy_service" "HTTPS" {
  provider = nsxt.global_manager
  display_name = "HTTPS"
}
data "nsxt_policy_service" "ICMPv4-ALL"{
  provider = nsxt.global_manager
  display_name = "ICMPv4-ALL"
}
data "nsxt_policy_service" "MySQL"{
  provider = nsxt.global_manager
  display_name = "MySQL"
}

resource "nsxt_policy_security_policy" "stretched-dfw" {
  provider = nsxt.global_manager
  display_name = "WebApp Stretched Policy"
  description  = "2-tier webapp Security Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false
  scope        = [nsxt_policy_group.g-web-stretched.path, nsxt_policy_group.g-db-stretched.path ]

  rule {
    display_name       = "Allow any to web"
    action             = "ALLOW"
    services           = [data.nsxt_policy_service.HTTPS.path, data.nsxt_policy_service.ICMPv4-ALL.path ]
    logged             = true
    destination_groups = [nsxt_policy_group.g-web-stretched.path]
       }

  rule {
    display_name       = "Allow web to db"
    action             = "ALLOW"
    source_groups      = [nsxt_policy_group.g-web-stretched.path]
    services           = [data.nsxt_policy_service.MySQL.path]
    destination_groups = [nsxt_policy_group.g-db-stretched.path]
    logged             = true
       }

  rule {
    display_name       = "Allow webapp out"
    action             = "ALLOW"
    source_groups      = [nsxt_policy_group.g-web-stretched.path,nsxt_policy_group.g-db-stretched.path]
    logged             = true
       }

  rule {
    display_name     = "Deny any"
    action           = "DROP"
       }
}
