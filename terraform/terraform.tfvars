# vsphere  parameters
vcenter_server		= "vcsa-01b.corp.local"
vcenter_username	= "administrator@vsphere.local"
vcenter_password	= "VMware1!"
datacenter		= "Site-B"
datastore	        = "Site-B-NFS"
cluster  	        = "Cluster-02"
content_library_name    = "nsx-alb"
nsxt_cloud_vcenter_name = "vcsa-01b"
vcsa_cred_name          = "vcsa-01"

# avi parameters
avi_controller		= "avi-01a.corp.local"
avi_username		= "admin"
avi_password		= "VMware1!"
avi_version		= "22.1.3"
tenant                  = "admin"
ssl_cert                = "webapp.corp.local"

# NSX-T cloud configuration
nsxt_cloud_url = "nsxmgr-01b.corp.local"
nsxt_cloud_username = "admin"
nsxt_cloud_password = "VMware1!VMware1!"
nsxt_cloud_prefix = "alb-b"
cloud_name = "nsxmgr-01b"
nsxt_cloud_cred_name = "nsxmgr-01"

# NSX-T Overlay Management Segment
nsxt_cloud_mgmt_tz_name = "nsx-overlay-transportzone"
nsxt_cloud_mgmt_tz_type = "OVERLAY"
nsxt_mgmt_lr_id = "t1-internal"
#nsxt_mgmt_segment_id = "ov-se-mgmt"

# NSX-T Data Segment
nsxt_cloud_data_tz_name = "nsx-overlay-transportzone"
nsxt_cloud_data_tz_type = "OVERLAY"
nsxt_cloud_lr1 = "t1-internal"
#nsxt_cloud_overlay_seg1 = "ov-lb-vip"
