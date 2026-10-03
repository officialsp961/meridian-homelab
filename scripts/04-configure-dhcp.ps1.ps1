Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-Service dhcpserver
Add-DhcpServerInDC -DnsName "DC01.corp.meridian.lab" -IPAddress 10.10.10.10
Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2

Add-DhcpServerv4Scope -Name "Meridian-Clients" -StartRange 10.10.10.100 -EndRange 10.10.10.200 -SubnetMask 255.255.255.0 -LeaseDuration 8.00:00:00 -State Active
Set-DhcpServerv4OptionValue -ScopeId 10.10.10.0 -Router 10.10.10.1 -DnsServer 10.10.10.10,10.10.10.11 -DnsDomain "corp.meridian.lab"