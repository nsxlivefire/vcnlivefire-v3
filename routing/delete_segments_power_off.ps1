Connect-VIServer -Server vcsa-01a.corp.local -user administrator@vsphere.local -Password VMware1!
#$T1="ov-tenant1"
#$T2="ov-tenant2"
$AA="ov-clients-stateful"
$NEWDVPG="Site-A-vDS-01-Mgmt"
#Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $T1 } |Set-NetworkAdapter -connected:$false -Confirm:$false
#Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $T2 } |Set-NetworkAdapter -connected:$false -Confirm:$false
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $AA } |Set-NetworkAdapter -connected:$false -Confirm:$false
#Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $T1 } |Set-NetworkAdapter -Portgroup $NEWDVPG -Confirm:$false
#Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $T2 } |Set-NetworkAdapter -Portgroup $NEWDVPG -Confirm:$false
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $AA } |Set-NetworkAdapter -Portgroup $NEWDVPG -Confirm:$false
#Stop-VM -VM "tenant1-vm" -Confirm:$False
#Stop-VM -VM "tenant2-vm" -Confirm:$False
Stop-VM -VM "clients-stateful-vm" -Confirm:$False
$username="admin"
$password="VMware1!VMware1!"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
#$Uri = "https://192.168.110.15/policy/api/v1/infra/segments/ov-tenant1"
#$Urii = "https://192.168.110.15/policy/api/v1/infra/segments/ov-tenant2"
$Uriii = "https://192.168.110.15/policy/api/v1/infra/segments/ov-clients-stateful"
#Invoke-RestMethod -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri $Uri -Method Delete
#Invoke-RestMethod -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri $Urii -Method Delete
Invoke-RestMethod -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri $Uriii -Method Delete
















