# Phase 2: Golden Image

**Date:** 10-02-2026
**Time spent:** 4 hours (mostly waiting on server updates)
**Status:** Done
**Branch:** phase/02-golden-image

## Objective
Create a golden image that every server will be built from, and learn how Sysprep and
image cloning work.

## Prerequisites
- Hyper-V enabled, with the `LAB-NAT` virtual switch from [Phase 1](01-hyperv-network.md)
- Windows Server 2022 evaluation ISO downloaded to `D:\Hyper-V\ISOs`

## Steps performed
1. Used a PowerShell script (drafted with Claude, then edited by me to ensure proper ISO paths and drive layout) to create the template VM without clicking through
   the GUI. See [related files](#related-files).
2. Installed Windows Server 2022 Standard (Desktop Experience).

   ![Windows Server installation](../images/phase02/01-Install-Windows-Server.png)

   *Figure 1: Windows Server 2022 setup on the template VM.*

3. Gave the VM a temporary static address (`10.10.10.250`, gateway `10.10.10.1`) so it
   could reach the internet for updates.
4. Patched the server with `sconfig` option 6, rebooting until no updates remained.
5. Configured the basics:
   - Time zone: `Set-TimeZone -Id "Eastern Standard Time"`
   - Remote Desktop enabled with `sconfig` option 7
6. Returned networking to DHCP so no static address is baked into the image.
7. Ran Sysprep to remove the machine's identity (name, SID, and other unique data) and
   shut the VM down:
   `C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown`
8. Marked the template disk read-only so it cannot be changed by accident:
   `Set-ItemProperty -Path "D:\Hyper-V\Templates\TEMPLATE-WS2022.vhdx" -Name IsReadOnly -Value $true`
9. Created a clone helper, `New-LabVM` (drafted with Claude, then edited by me for
   better use of host hardware). It builds each VM on a small differencing disk that points at the
   template, so servers share the template's files and only store their own changes.
10. Used it to create DC01, DC02, FS01, and PS01, and added a 100 GB data disk to FS01.

## Verification
- `Test-Connection 8.8.8.8 -Count 2` succeeded and `nslookup microsoft.com` resolved,
  so the template had internet access and working DNS.
- `sconfig` option 6 reported no remaining updates.

  ![sconfig showing no updates available](../images/phase02/04-Patch-Windows-Server.png)

  *Figure 2: The template is fully patched.*

- `Get-VHD D:\Hyper-V\VHDs\DC01.vhdx` showed a Differencing disk whose parent is the template.
- `Get-VM` listed DC01, DC02, FS01, and PS01, all powered off.

## Problems encountered
- Sysprep failed with "Sysprep was not able to validate your Windows installation."
  [Golden image Sysprep error](../troubleshooting/phase02/02-golden-image-sysprep-error.md)

  ![Sysprep error message](../images/phase02/06-Sysprep-Error.png)

  *Figure 3: Failed package removed.*

## What I learned
- Building VMs from a template is far faster than installing each one by hand. Differencing
  disks also save disk space, because every server shares the template's Windows files.
- Sysprep removes a machine's identity so clones can each start fresh, and a template
  should not be booted after it has been generalized.
- `sconfig` is a quick way to handle patching, remote desktop, network settings, and
  naming on a server.

## Related files
- Scripts:
  - [Template VM script](../../scripts/02-golden-image-new-template-vm.ps1)
- Docs: [IP plan](../overview/ip-plan.md)