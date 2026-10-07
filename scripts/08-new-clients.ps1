Set-ItemProperty -Path "D:\Hyper-V\Templates\TEMPLATE-WIN10.vhdx" -Name IsReadOnly -Value $true
$tpl    = "D:\Hyper-V\Templates\TEMPLATE-WIN10.vhdx"
$useTpm = $true
if ($useTpm) { $guardian = Get-HgsGuardian -Name "UntrustedGuardian" }

$names = (1..10 | ForEach-Object { "CL{0:D2}" -f $_ }) + "MGMT01"
foreach ($n in $names) {
    $vhd = "D:\Hyper-V\VHDs\$n.vhdx"
    New-VHD -Path $vhd -ParentPath $tpl -Differencing | Out-Null
    New-VM -Name $n -Generation 2 -MemoryStartupBytes 2GB -VHDPath $vhd -SwitchName "LAB-NAT" -Path "D:\Hyper-V\VMs" | Out-Null
    Set-VM -Name $n -ProcessorCount 2 -DynamicMemory -MemoryMinimumBytes 1GB -MemoryMaximumBytes 4GB -AutomaticCheckpointsEnabled $false
    Set-VMFirmware -VMName $n -EnableSecureBoot On
    if ($useTpm) {
        $kp = New-HgsKeyProtector -Owner $guardian -AllowUntrustedRoot
        Set-VMKeyProtector -VMName $n -KeyProtector $kp.RawData
        Enable-VMTPM -VMName $n
    }
    Write-Host "Created $n" -ForegroundColor Green
}