$name   = "TEMPLATE-WIN10"
$iso    = "D:\Hyper-V\ISOs\Win10-Pro-22H2.iso"   # adjust to your file name
$useTpm = $true                                  # optional for Windows 10, needed for BitLocker later

New-VM -Name $name -Generation 2 -MemoryStartupBytes 2GB -NewVHDPath "D:\Hyper-V\Templates\$name.vhdx" -NewVHDSizeBytes 60GB -SwitchName "LAB-NAT" -Path "D:\Hyper-V\VMs"
Set-VM -Name $name -ProcessorCount 2 -AutomaticCheckpointsEnabled $false
Set-VMFirmware -VMName $name -EnableSecureBoot On

if ($useTpm) {
    $guardian = Get-HgsGuardian -Name "UntrustedGuardian" -ErrorAction SilentlyContinue
    if (-not $guardian) { $guardian = New-HgsGuardian -Name "UntrustedGuardian" -GenerateCertificates }
    $kp = New-HgsKeyProtector -Owner $guardian -AllowUntrustedRoot
    Set-VMKeyProtector -VMName $name -KeyProtector $kp.RawData
    Enable-VMTPM -VMName $name
}

Add-VMDvdDrive -VMName $name -Path $iso
Set-VMFirmware -VMName $name -FirstBootDevice (Get-VMDvdDrive -VMName $name)
Start-VM $name
vmconnect.exe localhost $name