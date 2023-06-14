Connect-VIServer -Server vcsa-01b.corp.local -user administrator@vsphere.local -Password VMware1!
$DRUVM="drupal"
$MARVM="mariadb"
Get-VM | Where {$_.Name -match $DRUVM} | Start-VM
Get-VM | Where {$_.Name -match $MARVM} | Start-VM
