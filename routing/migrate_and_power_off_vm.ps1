Connect-VIServer -Server vcsa-01a.corp.local -user administrator@vsphere.local -Password VMware1!
$AA="ov-clients-stateful"
$NEWDVPG="Site-A-vDS-01-Mgmt"
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $AA } |Set-NetworkAdapter -connected:$false -Confirm:$false
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $AA } |Set-NetworkAdapter -Portgroup $NEWDVPG -Confirm:$false
Stop-VM -VM "clients-stateful-vm" -Confirm:$False
