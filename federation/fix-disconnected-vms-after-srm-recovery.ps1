Connect-VIServer -Server vcsa-01b.corp.local -user administrator@vsphere.local -Password VMware1!
Get-VM web-01a | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup Site-B-vDS-01-Mgmt -Confirm:$false
Get-VM web-01a | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup ov-web-stretched -Confirm:$false
Get-VM web-01a | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false

Get-VM web-02a | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup Site-B-vDS-01-Mgmt -Confirm:$false
Get-VM web-02a | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup ov-web-stretched -Confirm:$false
Get-VM web-02a | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false

Get-VM db-01a | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup Site-B-vDS-01-Mgmt -Confirm:$false
Get-VM db-01a | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup ov-db-stretched -Confirm:$false
Get-VM db-01a | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false
