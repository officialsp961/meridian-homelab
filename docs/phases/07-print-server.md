# Phase 7: Print Server

**Date:** 10-04-2026
**Time spent:** 3 hours
**Status:** Done
**Branch:** phase/07-print-server

## Objective
Build a print server (`PS01`) that hosts seven printer queues: one for each department and
one common printer. Each department can print only to its own printer, and the common
printer is open to everyone.

## Prerequisites
- Domain, users, and groups from [Phase 5](05-ou-users-groups.md)
- PS01 created from the golden image ([Phase 2](02-golden-image.md))

## Steps performed
1. Planned the queues: one printer per department, the groups that control access, and a
   fake static IP for each. The result is the [printer plan](../decisions/phase07.md).
2. Created the print groups on DC01 (`DL-Print-<Dept>` and `DL-Print-Common`) and added the
   matching `GG-` groups as members, following the same pattern as the file shares.

   ![Print groups and their members](../images/phase07/02-print-groups-members.png)

   *Figure 1: The print groups and their members.*

3. Prepared the print server: set its address and name, joined it to the domain, and
   installed the Print and Document Services role with **Add Roles and Features**.
4. Added the printers with **Print Management**. The printers use the Microsoft PS Class
   Driver and TCP/IP ports pointed at fake addresses (`10.10.10.50` to `.56`), since there
   is no physical hardware.
   - Created `IT-PRN-01` and `FIN-PRN-01` by hand: added the printer by IP address, shared it,
     listed it in the directory, removed Everyone, and gave the department's print group the
     Print permission.
   - Created the other five with a PowerShell script (drafted with Claude, then edited by me
     to skip IT and Finance and to leave directory publishing to the console).

   ![Printer list in Print Management](../images/phase07/04-printer-list.png)

   *Figure 2: The seven printer queues on PS01.*

5. Hardened the domain controllers by stopping the Print Spooler service and setting its
   startup type to Disabled on DC01 and DC02. A DC does not print, and the Spooler has a
   history of serious vulnerabilities such as PrintNightmare.
6. Backed up the print queues with the **Migrate Printers** wizard in Print Management,
   saving a `.printerExport` file.

## Verification
1. Tested the backup: deleted one printer, then imported it back from the backup file, and
   confirmed its sharing and security settings returned.
2. Finance user can connect
   to `\\PS01\FIN-PRN-01` and is denied on `\\PS01\HR-PRN-01`. The client tests were done in
   [Phase 8](08-clients.md) and [Phase 9](09-group-policy.md).

## What I learned
1. The Print Spooler has a long history of serious vulnerabilities and domain controllers
   do not need it, so I disabled it on both DCs to reduce their attack surface.

## Related files
- [Printer plan](../decisions/phase07.md)
- Runbook: [Clearing a stuck print queue](../runbooks/phase07/print-spool-clear.md)