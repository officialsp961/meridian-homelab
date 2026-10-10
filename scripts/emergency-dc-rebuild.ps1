param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Name,
    [string]$Template = "D:\Hyper-V\Templates\TEMPLATE-WS2022.vhdx",
    [string]$VhdPath  = "D:\Hyper-V\VHDs",
    [string]$VmPath   = "D:\Hyper-V\VMs",
    [string]$Switch   = "LAB-NAT",
    [int64]$RAM       = 2GB,
    [int]$CPU         = 2
)

# Safety checks
if (-not (Test-Path $Template)) { throw "Template not found: $Template" }
if (Get-VM -Name $Name -ErrorAction SilentlyContinue) { throw "A VM named $Name already exists." }

# Use a new disk name if the old file is still around (for example, locked)
$vhd = Join-Path $VhdPath "$Name.vhdx"
if (Test-Path $vhd) {
    $vhd = Join-Path $VhdPath "$Name-new.vhdx"
    Write-Warning "Old disk exists. Using $vhd instead."
}

# Build the VM on a differencing disk and start it
New-VHD -Path $vhd -ParentPath $Template -Differencing | Out-Null
New-VM -Name $Name -Generation 2 -MemoryStartupBytes $RAM -VHDPath $vhd -SwitchName $Switch -Path $VmPath | Out-Null
Set-VM -Name $Name -ProcessorCount $CPU -DynamicMemory -MemoryMinimumBytes 1GB -MemoryMaximumBytes ($RAM * 2) -AutomaticCheckpointsEnabled $false
Start-VM -Name $Name
vmconnect.exe localhost $Name
Write-Host "$Name created from the golden image and started." -ForegroundColor Green