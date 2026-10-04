# Runbook: Clear a stuck print queue

**Applies to:** PS01 (print server)
**Who can do it:** Helpdesk or an administrator with admin rights on PS01
**Time needed:** About 2 minutes

## When to use this
- A print job sits in the queue and never prints or deletes.
- The printer queue shows "Deleting" or "Error" for a long time.
- Users report that nothing prints and the queue won't clear.

## Check first
1. Confirm the printer itself is reachable and not just paused or offline.
2. Try deleting the job normally: in Print Management, open the printer, select the job, and choose Cancel. If it disappears, you're done.

## Steps
1. Sign in to PS01 with an admin account (or connect with Print Management from MGMT01).
2. Open an elevated PowerShell window (Run as administrator).
3. Stop the Print Spooler service:
```powershell
   Stop-Service Spooler
```
4. Delete the stuck job files:
```powershell
   Remove-Item C:\Windows\System32\spool\PRINTERS\* -Force
```
5. Start the Print Spooler service:
```powershell
   Start-Service Spooler
```

## Verify it worked
```powershell
Get-Service Spooler
Get-PrintJob -PrinterName "FIN-PRN-01"
```
- `Spooler` should show `Running`.
- `Get-PrintJob` should return no stuck jobs.
- Ask the user to print a test page, and confirm it appears in the queue.

## Notes
- Deleting these files cancels every waiting job on the server, not just the stuck one. Tell users to resend anything that didn't print.
- Only delete files inside `spool\PRINTERS`. Don't touch other folders under `spool`, because they hold printer drivers and settings.
- If the job comes back after restarting the Spooler, the printer driver may be at fault. Check the printer's driver and port, and note it in the troubleshooting log.

## History
- 10-4-2026: Created.