function New-LabVM {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Template = "D:\Hyper-V\Templates\TEMPLATE-WS2022.vhdx",
        [int]$CPU = 2,
        [int64]$RAM = 2GB,
        [string]$Switch = "LAB-NAT"
    )
    $vhd = "D:\Hyper-V\VHDs\$Name.vhdx"
    New-VHD -Path $vhd -ParentPath $Template -Differencing | Out-Null
    New-VM -Name $Name -Generation 2 -MemoryStartupBytes $RAM -VHDPath $vhd -SwitchName $Switch -Path "D:\Hyper-V\VMs" | Out-Null
    Set-VM -Name $Name -ProcessorCount $CPU -DynamicMemory -MemoryMinimumBytes 1GB -MemoryMaximumBytes ($RAM * 2) -AutomaticCheckpointsEnabled $false
    Write-Host "Created $Name" -ForegroundColor Green
}

# Create the four servers (not powered on yet)
New-LabVM -Name "DC01"
New-LabVM -Name "DC02"
New-LabVM -Name "FS01"
New-LabVM -Name "PS01"