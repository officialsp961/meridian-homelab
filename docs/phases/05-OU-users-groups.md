# Phase 5: OUs, Users, and Groups

**Date:** 10-03-2026
**Time spent:** 2 hours
**Status:** Done
**Branch:** phase/05-ou-users-groups

## Objective
Design and build a clean, scalable OU structure for six departments, with role-based
security groups and 30 user accounts.

## Prerequisites
- Two healthy domain controllers ([Phase 4](04-dc02-dhcp.md))
- A user list (`data/users.csv`) of 30 invented employees, five per department

## Steps performed
1. Sketched the OU structure on a whiteboard, then used a PowerShell script (drafted with
   Claude, run by me) to create the OUs and security groups. I scripted this to save time,
   since I already have experience creating OUs and groups by hand. The design is explained
   in the [decision record](../decisions/phase05.md).

   ![OU structure in Active Directory Users and Computers](../images/phase05/01-OU-Creation.png)

   *Figure 1: The OU hierarchy and groups after the script ran.*

2. Redirected new computers into the `New Computers` OU with `redircmp`, so newly joined PCs
   land somewhere Group Policy can be linked instead of the default Computers container.
3. Created the 30 users:
   - Wrote `data/users.csv` with first name, last name, department, and title
   - Ran a user-creation script, adapted from one I use at work, which creates each account
     in its department OU and adds it to its `GG-` group and `GG-All-Staff`
4. Made the groups useful: delegated **Reset user passwords and force password change at next
   logon** on the `Departments` OU to `GG-IT-Helpdesk`, using the **Delegation of Control
   Wizard** in Active Directory Users and Computers.
5. Created my own admin account, `sperry`, in the `Admin Accounts` OU with
   **Active Directory Users and Computers**, and added it to Domain Admins.
6. Enabled the Active Directory Recycle Bin, so deleted objects can be restored with their
   attributes. 

## Verification
- `Get-ADUser -Filter * -SearchBase "OU=Meridian,DC=corp,DC=meridian,DC=lab"` listed all 30
  users, five in each department.

## What I learned
- You can change the default location for new computer accounts with `redircmp`. I
  did not know that, it is useful for my current workflow, and I plan to raise it with
  our administration team.

## Related files
- Scripts:
  - [OU and group creation](../../scripts/06-new-ou-structure.ps1)
  - [User creation](../../scripts/07-new-ad-users.ps1)
- [Decision record: OU structure](../decisions/phase05.md)