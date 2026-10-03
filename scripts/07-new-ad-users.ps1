Import-Module ActiveDirectory
$csv   = Import-Csv "C:\Users\Administrator\Downloads\users.csv"
$root  = "OU=Meridian,DC=corp,DC=meridian,DC=lab"
$upn   = "corp.meridian.lab"
$initialPwd = Read-Host -AsSecureString "Enter the initial password for new users"

foreach ($u in $csv) {
    $sam  = ("{0}.{1}" -f $u.FirstName, $u.LastName).ToLower()
    $path = "OU=Users,OU=$($u.Department),OU=Departments,$root"

    if (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
        Write-Warning "$sam already exists, skipping"
        continue
    }

    New-ADUser -Name "$($u.FirstName) $($u.LastName)" `
        -GivenName $u.FirstName -Surname $u.LastName `
        -DisplayName "$($u.FirstName) $($u.LastName)" `
        -SamAccountName $sam -UserPrincipalName "$sam@$upn" `
        -Title $u.JobTitle -Department $u.Department -Company "Meridian Dynamics" `
        -Path $path -AccountPassword $initialPwd -Enabled $true -ChangePasswordAtLogon $true

    Add-ADGroupMember -Identity "GG-$($u.Department)" -Members $sam
    Add-ADGroupMember -Identity "GG-All-Staff"         -Members $sam
    Write-Host "Created $sam" -ForegroundColor Green
}