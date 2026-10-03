$name = "TEMPLATE-WS2022"
$vhd  = "D:\Hyper-V\Templates\$name.vhdx"
$iso  = "D:\Hyper-V\ISOs\SERVER_EVAL_x64FRE_en-us.iso" 

New-VM -Name $name -Generation 2 -MemoryStartupBytes 4GB -NewVHDPath $vhd -NewVHDSizeBytes 60GB -SwitchName "LAB-NAT" -Path "D:\Hyper-V\VMs"
Set-VM -Name $name -ProcessorCount 2 -AutomaticCheckpointsEnabled $false
Add-VMDvdDrive -VMName $name -Path $iso
$dvd = Get-VMDvdDrive -VMName $name
Set-VMFirmware -VMName $name -FirstBootDevice $dvd
Start-VM $name
vmconnect.exe localhost $name