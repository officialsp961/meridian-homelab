Import-Module ActiveDirectory
$base  = "DC=corp,DC=meridian,DC=lab"
$root  = "OU=Meridian,$base"
$depts = "IT","HR","Finance","Sales","Marketing","Operations"

New-ADOrganizationalUnit -Name "Meridian" -Path $base
foreach ($ou in "Departments","Servers","Groups","Admin Accounts","Service Accounts","New Computers","Disabled Objects") {
    New-ADOrganizationalUnit -Name $ou -Path $root
}
foreach ($d in $depts) {
    New-ADOrganizationalUnit -Name $d -Path "OU=Departments,$root"
    foreach ($sub in "Users","Computers") {
        New-ADOrganizationalUnit -Name $sub -Path "OU=$d,OU=Departments,$root"
    }
}
New-ADOrganizationalUnit -Name "Global Groups"       -Path "OU=Groups,$root"
New-ADOrganizationalUnit -Name "Domain Local Groups" -Path "OU=Groups,$root"

# Groups
$gPath = "OU=Global Groups,OU=Groups,$root"
$lPath = "OU=Domain Local Groups,OU=Groups,$root"
foreach ($d in $depts) {
    New-ADGroup -Name "GG-$d" -GroupScope Global -GroupCategory Security -Path $gPath -Description "All $d staff"
    New-ADGroup -Name "DL-$d-Share-RW" -GroupScope DomainLocal -GroupCategory Security -Path $lPath -Description "Modify access to the $d share"
    New-ADGroup -Name "DL-$d-Share-RO" -GroupScope DomainLocal -GroupCategory Security -Path $lPath -Description "Read-only access to the $d share"
    Add-ADGroupMember -Identity "DL-$d-Share-RW" -Members "GG-$d"    # the AGDLP link
}
New-ADGroup -Name "GG-All-Staff"     -GroupScope Global -GroupCategory Security -Path $gPath -Description "Every employee"
New-ADGroup -Name "GG-IT-Helpdesk"   -GroupScope Global -GroupCategory Security -Path $gPath -Description "Delegated password reset rights"