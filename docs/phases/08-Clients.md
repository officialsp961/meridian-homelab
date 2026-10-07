# Phase 08: Clients

**Date:** 10-5-2026
**Time spent:** 5 hours
**Status:** Done
**Branch:** 08-clients

## Objective
1. Build 10 Windows 10 Pro client PCs joined to the domain and sorted into department OUs, plus an admin workstation (MGMT01) with remote administration tools.

## Steps performed
1. Use template script to automate VM creation.
2. Install Windows 10 Pro
3. Installed updates and global software
    - Entered audit mode
    - Set temporary network settings
    - Installed all windows updates
    - Installed software I wanted on all images
        - Notepad ++
        - 7-zip
    - Cleared borowser cache, deleted donwloaded files, and removed netowrk config.
    - Entered OOBE
    - ![Sysprep](../images/phase08/win-10-sysprep.png)
        *Sysprep*
    - Debloated windows by removing pre-installed applications
4. Used script to automate client creation using template
5. Setup client machines and join domain
6. Set up management machine
    - This machine will be used for management purposes moving forward, limitng the amout of time I spend logged into the DC
    - Set static IP outside of DHCP scope
    - Install RSAT tools

## Verification
1. ![Clients-in-AD](../images/phase08/Verification-in-AD.png)
    
    *Clients in AD*

2. ![Clients-DHCP](../images/phase08/Verification-DHCP.png)
    
    *Clients received DHCP leases*

3. ![Clients-DNS](../images/phase08/Verification-DNS.png)
    
    *Clients in DNS pool*

4. ![User-Login-File-Access](../images/phase08/Verification-User-login-domain-homefolder.png)

    *Domain user signed in on a domain-joined PC, with access to the home folder and department shares.*

5. ![Folder-Permissions](../images/phase08/Verification-Folder-Permissions.png)

    *Finance user browses `\\corp.meridian.lab\shares`. They can open Finance and create a file there (`write-to-share`), but opening HR returns "You do not have permission to access."*

6. ![File-Screen](../images/phase08/Verification-File-Screen.png)

    *User is unable to save .exe files*

7. ![Printer-Permissions](../images/phase08/Verification-Printer-Permissions.png)

    *User can only access the Finance printer*

8. ![Delegated-Control](../images/phase08/Verification-Delegated-Control.png)

    *IT Helpdesk user has access to reset passwords for delegated folders, but not admin users.*

# Related Files
1. [Script](../../scripts/08-win10-template.ps1)
2. [Script-clients](../../scripts/08-new-clients.ps1)