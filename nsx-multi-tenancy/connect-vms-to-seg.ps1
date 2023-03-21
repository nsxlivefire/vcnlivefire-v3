Connect-VIServer -Server vcsa-01a.corp.local -user administrator@vsphere.local -Password VMware1!
$DEVVM="dev-"
$PRDVM="prd-"
$DEVSEG="ov-project-dev"
$PRDSEG="ov-project-prd"
Get-VM | Where {$_.Name -match $DEVVM} | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $DEVSEG -Confirm:$false
Get-VM | Where {$_.Name -match $PRDVM} | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $PRDSEG -Confirm:$false
Get-VM | Where {$_.Name -match $DEVVM} | Start-VM
Get-VM | Where {$_.Name -match $PRDVM} | Start-VM
