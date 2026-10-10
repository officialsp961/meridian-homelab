# Phase 9: Group Policy

**Date:** 10-07-2026
**Time spent:** 3 hours
**Status:** Done
**Branch:** phase/09-group-policy

## Objective
Create Group Policy Objects and link them to OUs to control settings and resources:
branding, security settings, restrictions, drive and printer mapping, and local admin access.

## Prerequisites
- Clients joined to the domain and sorted into department OUs ([Phase 8](08-clients.md))
- The `Branding` share on FS01 holding the lock screen and wallpaper images
  ([Phase 6](06-file-server.md))

## Steps performed
All GPOs were built by hand in **Group Policy Management**.

1. Created the Central Store of policy templates by copying `PolicyDefinitions` into SYSVOL,
   so every admin sees the same settings.

   ![Central Store creation and verification](../images/phase09/central-store.png)

   *Figure 1: Commands creating and verifying the Central Store folder.*

2. Set the domain password policy in the Default Domain Policy.

   ![Password policy](../images/phase09/password-policy.png)

   *Figure 2: The password and lockout settings applied.*

3. Created a lock screen GPO:
   - A Files preference copies the lock screen image from the `Branding` share on FS01 to
     a local folder on every PC, so the image can be changed at any time by replacing one file.
   - Registry preference items work around Windows 10 Pro ignoring the lock screen policy.
4. Created a separate wallpaper GPO that sets the desktop wallpaper from the `Branding` share.
5. Created a security GPO that sets the logon message: "This system belongs to Meridian
   Dynamics. Use is monitored. Unauthorized access is prohibited." 
6. Created a GPO that blocks removable storage (USB) for all non-IT users, linked to the
   five non-IT department OUs.
7. Created a user restrictions GPO, linked to the five non-IT department OUs, that blocks:
   - All Control Panel items except Mouse
   - The Settings app
   - Command Prompt
   - The Registry Editor

   ![User restrictions GPO](../images/phase09/user-restrictions.png)

   *Figure 3: The restriction settings in the GPO.*

8. Created a drive and printer GPO for each department, linked to the department OU:
   - Mapped the Public share to all users as `P:`
   - Mapped each department's share as `S:`
   - Mapped the department's printer and set it as the default
9. Created a GPO that gives the helpdesk local administrator rights on department PCs, using
   a Group Policy Preference that adds `GG-IT-Helpdesk` to each computer's local
   Administrators group.
10. Ran two "break it on purpose" tests:
    - Turned on **Block Inheritance** on the Finance OU, and the lock screen and wallpaper
      policies stopped applying.
    - Set those policies to **Enforced**, and they applied again despite the block.
11. Backed up all GPOs with `Backup-GPO`, and saved an HTML report.

## Verification
1. The lock screen policy works on a Windows 10 Pro client.

   ![Lock screen GPO working](../images/phase09/Verification-lockscreen-gpo.png)

   *Figure 4: The branded lock screen.*

2. The wallpaper policy works.

   ![Wallpaper GPO working](../images/phase09/Verification-wallpaper-gpo.png)

   *Figure 5: The branded desktop wallpaper.*

3. The restrictions work: Command Prompt, the Registry Editor, and USB access are blocked.

   ![User restrictions in effect](../images/phase09/Verification-user-restrictions.png)

   *Figure 6: Blocked tools for a restricted user.*

4. The logon message appears before sign-in.

   ![Logon message](../images/phase09/Verification-logon-message.png)

   *Figure 7: The logon message shown at the sign-in screen.*

5. The department printer mapped after a policy update.

   ![Printer mapped by GPO](../images/phase09/Verification-printer-mapped.png)

   *Figure 8: The printer appears for the HR user after the fix.*

## Problems encountered
1. **The department printer did not map.** The report showed the printer item failing with
   error `0x80070005` (access denied), even though the user could connect by hand.
   See the [printer troubleshooting entry](../troubleshooting/phase09/09-printer-map-failure.md).

## Changes made to the plan
1. Split the lock screen and wallpaper into two GPOs.
2. Renamed some GPOs from the plan

## What I learned
1. A Group Policy Preference can add a domain security group to the local Administrators
   group on every PC in an OU. With it, `GG-IT-Helpdesk` has admin rights on all department
   computers with no shared local password, and access follows group membership: adding or
   removing someone from the group is the only change needed.


## Related files
- Troubleshooting:
  - [Printer not mapping](../troubleshooting/phase09/09-printer-map-failure.md)
  - [Break test: computer in the wrong OU](../troubleshooting/phase09/09-gpo-computer-in-wrong-ou.md)
  - [Break test: block inheritance and Enforced](../troubleshooting/phase09/09-gpo-block-inheritance-enforced.md)
- [GPO backups](../../gpo-backups/GPOBackup/)