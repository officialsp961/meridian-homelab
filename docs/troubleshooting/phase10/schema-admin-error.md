# Problem: Update-LapsADSchema fails while the second domain controller is offline

**Date:** 10-10-2026
**Type:** Unplanned issue found during setup

## Symptom
Running `Update-LapsADSchema` on DC01 failed on the first attribute with:

```text
Add request for 'CN=ms-LAPS-Password,CN=Schema,CN=Configuration,DC=corp,DC=meridian,DC=lab'
threw exception: System.DirectoryServices.Protocols.DirectoryOperationException:
An operation error occurred.
```

The error was the same on every retry. DC02 had been powered off.

## Troubleshooting steps
1. **First failure: insufficient rights.** The command failed even from a Domain Admin account.
   Schema changes need membership in **Schema Admins**, which Domain Admins do not have.
   I ran powershell as the local admin for the DC to resolve the permissions issue.
2. **Checked the sign-in token.** `whoami /groups | findstr /i "Schema"` showed
   `MERIDIAN\Schema Admins` enabled, so rights were no longer the problem.
3. **Checked where the command ran.** `netdom query fsmo` showed DC01 holds all five FSMO
   roles, including Schema master, so I was running it on the right server.
4. **Checked replication.** `repadmin /replsummary` showed every attempt to reach DC02
   failing with error 1722 ("The RPC server is unavailable"), with a largest delta of
   4 days 15 hours, matching how long DC02 had been off.
5. **Powered on DC02**, waited for its services to start, and rechecked.
   `repadmin /replsummary` then showed 0 failures out of 5, with deltas around 1.5 minutes.

## Cause
The schema update would not complete while DC02 was unreachable. With DC02 off, 
replication to it was failing, and the schema write was refused.
The cmdlet's error ("An operation error occurred") did not say this, and I identified it by
elimination and research.

## Fix
Powered on DC02, waited until `repadmin /replsummary` reported no failures, and ran
`Update-LapsADSchema` again. It completed successfully.

## How to prevent it
- Before any schema or other forest-wide change, start both domain controllers and check
  `repadmin /replsummary` for zero failures.
- Schema changes cannot be undone, so confirm the replication state first, and have a
  current system state backup of the schema master.

## What I learned
- A generic error can have a cause that is not in the message. Ruling out causes one by
  one (rights, role holder, replication) found it.
- Schema changes depend on the health of all domain controllers, not only the one running
  the command.