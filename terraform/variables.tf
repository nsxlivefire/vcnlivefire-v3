variable "avi_username" {
  type    = string
}
variable "avi_password" {
  type    = string
}
variable "avi_version" {
  type    = string
}
variable "tenant" {
  type    = string
}
variable "cloud_name" {
  type    = string
}
variable "nsxt_cloud_cred_name" {
  type    = string
}
variable "vcsa_cred_name" {
  type    = string
}
variable "vcenter_username" {
  type    = string
}
variable "vcenter_password" {
  type    = string
}
variable "vcenter_server" {
  type    = string
}
variable "content_library_name" {
  type    = string
}
variable "datacenter" {
  type    = string
}
variable "datastore" {
  type    = string
}
variable "cluster" {
  type    = string
}
variable "nsxt_cloud_url" {
  type    = string
}
variable "nsxt_cloud_username" {
  type    = string
}
variable "nsxt_cloud_password" {
  type    = string
}
variable "nsxt_cloud_prefix" {
  type    = string
}
variable "nsxt_cloud_vcenter_name" {
  type    = string
}
variable "nsxt_cloud_mgmt_tz_name" {
  type    = string
}
variable "nsxt_cloud_data_tz_name" {
  type    = string
}
variable "nsxt_cloud_mgmt_tz_type" {
  type    = string
}
variable "nsxt_cloud_data_tz_type" {
  type    = string
}
variable "nsxt_mgmt_lr_id" {
  type    = string
}
#variable "nsxt_mgmt_segment_id" {
#  type    = string
#}
variable "nsxt_cloud_lr1" {
  type    = string
}
#variable "nsxt_cloud_overlay_seg1" {
#  type    = string
#}

variable "nsxmgr-01a_ip" {
    type    = string
    default = "192.168.110.15"
}
variable "nsxmgr-01b_ip" {
    type    = string
    default = "192.168.210.15"
}
variable "nsxgmgr-01a_ip" {
    type    = string
    default = "192.168.110.16"
}
variable "nsx_username" {
    type    = string
    default = "admin"
}
variable "nsx_password" {
    type    = string
    default = "VMware1!VMware1!"
}
variable "avi_controller" {
  type    = string
}
variable "vs_name" {
  type    = string
  default = "webapp-vs-siteb"
}
variable "dns_vs_name" {
  type    = string
  default = "dns-s-siteb"
}
variable "pool_name" {
  type    = string
  default = "webapp-vs-siteb-pool"
}
variable "lb_algorithm" {
  type    = string
  default = "LB_ALGORITHM_ROUND_ROBIN"
}
variable "server1_ip" {
  type    = string
  default = "172.16.10.11"
}
variable "server2_ip" {
  type    = string
  default = "172.16.10.12"
}
variable "server1_port" {
  type    = number
  default = 443
}
variable "server2_port" {
  type    = number
  default = 443
}
variable "vs_address" {
  type    = string
  default = "172.26.100.10"
}
variable "dns_vs_address" {
  type    = string
  default = "172.26.100.2"
}
variable "vs_port" {
  type    = number
  default = "443"
}
variable "ssl_profile" {
  type    = string
  default = "System-Standard"
}
variable "healthmonitor" {
  type    = string
  default = "System-HTTPS"
}
variable "pool_default_server_port" {
  type    = number
  default = "443"
}
variable "serviceenginegroup" {
  type    = string
  default = "Default-Group"
}
variable "applicationprofile" {
  type    = string
  default = "System-Secure-HTTP"
}
variable "networkprofile" {
  type    = string
  default = "System-TCP-Proxy"
}
variable "ssl_cert" {
  type    = string
#  default = "webapp.corp.local"
}

