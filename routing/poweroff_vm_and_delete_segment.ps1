Connect-VIServer -Server vcsa-01a.corp.local -user administrator@vsphere.local -Password VMware1!
$AA="ov-clients-stateful"
$NEWDVPG="Site-A-vDS-01-Mgmt"
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $AA } |Set-NetworkAdapter -connected:$false -Confirm:$false
Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $AA } |Set-NetworkAdapter -Portgroup $NEWDVPG -Confirm:$false
Stop-VM -VM "clients-stateful-vm" -Confirm:$False
$username="admin"
$password="VMware1!VMware1!"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
$Uriii = "https://192.168.110.15/policy/api/v1/infra/segments/ov-clients-stateful"
Invoke-RestMethod -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri $Uriii -Method Delete
















