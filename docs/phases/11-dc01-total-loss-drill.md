# Drill: Total loss of a domain controller (DC01)

> **Planned drill: I broke this on purpose** to see how the domain behaves without DC01
> and how long it takes to recover. This was not an unplanned incident.

**Date:** 2026-10-10
**Result:** The domain kept working on DC02 the whole time. A rebuilt DC01 was signed in at
33:15 and replicating from DC02 at about 43:00, and full redundancy (DNS order, DHCP
failover, client checks) was confirmed at **55:45**.

## Scenario
DC01 held all five FSMO roles, DNS, and one half of the DHCP failover pair. I powered it off,
deleted it, and rebuilt it from the golden image while DC02 carried the domain.

## Setup
- Took system state backups of both domain controllers.
- Running during the drill: DC02, CL03, and FS01 (started after DC01 was gone). Everything
  else was off or saved, because the host has limited memory and a SATA SSD.
- Before starting, `repadmin /replsummary` showed no failures.

## Timeline
Times are elapsed on my stopwatch.

| Elapsed | Event |
| --- | --- |
| 0:00 | Timer started. Both DCs healthy. |
| 0:16 | DC01 powered off. |
| 1:20 | DC01 VM deleted. |
| 2:00 | FS01 up and a domain admin signed in. `\\corp.meridian.lab\Shares` opened from a client. |
| 3:30 | `nltest /dsgetdc:corp.meridian.lab` succeeded, returning DC02. |
| 3:47 | `ipconfig /release` and `/renew` on CL03 succeeded. |
| 4:15 | `nltest /dsgetdc` and `nltest /sc_verify` succeeded on FS01. |
| 13:14 | `netdom query fsmo` showed DC01 still holding all five roles. |
| 13:20 | Seized the roles to DC02. Three moved with a Domain Admin account, and two (Schema master and Domain naming master) failed with "Access is denied." |
| 13:30 | DC01 object removed from Active Directory (while working through the error). |
| 15:30 | DC01's NS record removed from DNS. |
| 21:30 | Rest of the cleanup: other DNS records, Sites and Services, DHCP failover relationship. |
| 22:00 | FS01 shut down to free memory. |
| 23:47 | Re-ran the Schema and Domain naming roles as the built-in Administrator, about 10 min 27 sec after the error. All five roles on DC02. |
| 24:00 | New DC01 VM running. |
| 26:00 | Renamed the server to `DC01`. |
| 27:15 | Static IP set. |
| 33:15 | Signed in on the rebuilt DC01 after promotion. **Replacement DC back.** |
| 43:00 | After waiting 10 minutes for services to settle, `repadmin /showrepl` showed successful replication from DC02 on all five partitions. |
| 55:45 | Full redundancy confirmed: DNS client order restored, DHCP failover rebuilt, clients checked. |

## What I did
1. **Broke it:** powered DC01 off, then deleted the VM.
2. **Proved the domain survived:** `nltest /dsgetdc` returned DC02, CL03 released and renewed
   its lease, a domain admin could sign in on FS01, and the DFS path opened from a client.
3. **Seized the FSMO roles** to DC02 with `Move-ADDirectoryServerOperationMasterRole`. There
   is no GUI for seizing, so this was PowerShell.
4. **Cleaned up DC01's remains** in the GUI: removed its object from the Domain Controllers
   OU ("permanently offline"), its DNS records, and its entry in Sites and Services.
5. **Rebuilt DC01** from the golden image, set its name and IP (DNS pointing at DC02), added
   the AD DS and DNS roles, and promoted it with the Server Manager wizard as an additional
   domain controller in the existing domain.
6. **Restored redundancy:** set each DC's DNS to the partner first and itself second,
   installed and authorized DHCP on DC01, and rebuilt the DHCP failover from DC02.
7. **Checked the lab** from a client and from FS01.

## Findings
1. **DHCP scope options were not in sync before the drill.** A client renewing from DC02
   received an address and gateway but no DNS servers, and fell back to `fec0:` addresses,
   so name lookups failed. I set option 6 (`10.10.10.10`, `10.10.10.11`) on both DHCP
   servers and replicated the scope.
   This would have broken every client once DC02 became the only DHCP server.
2. **Deleting the VM left its disks locked.** Three files remained in `D:\Hyper-V\VHDs`:
   `DC01.vhdx` and two checkpoint files (`.avhdx`, 6.3 GB and 13.8 GB) from earlier
   checkpoints. `Get-VM` no longer listed DC01, the disk was not mounted, and the only
   running `vmwp.exe` processes matched DC02 and CL03, so I did not identify the holder.
3. **FSMO roles seize in two permission tiers.** With a Domain Admin account, the PDC
   Emulator, RID master, and Infrastructure master moved to DC02. The Schema master and
   Domain naming master failed with "Access is denied," because they need **Schema Admins**
   and **Enterprise Admins**. I ran the seizure as the built-in Administrator, which holds
   both groups. I did not add
   Domain Admins to those groups, since they should stay empty except when needed.
4. **DC02's DNS settings pointed at the dead DC first.** DC02's DNS client list was
   `10.10.10.10, 127.0.0.1`, so every lookup waited for DC01 to time out. Asking DC02
   directly (`nslookup corp.meridian.lab 10.10.10.11`) answered immediately. I set DC02 to
   use itself first during the drill, then restored partner-first afterward.
5. **DC01's service records cleared from DNS.** After cleanup, the SRV lookup for domain
   controllers listed only DC02:
```text
   _ldap._tcp.dc._msdcs.corp.meridian.lab  SRV service location:
             priority = 0, weight = 100, port = 389
             svr hostname = dc02.corp.meridian.lab
   dc02.corp.meridian.lab  internet address = 10.10.10.11
```
6. **`repadmin /syncall` complained while replication was healthy.** On the new DC01,
   `/syncall /AdeP` reported "The following server could not be reached (topology
   incomplete)" for DC02 on every partition, even after waiting. At the same time,
   `repadmin /replsummary` showed 0 of 5 failures and `repadmin /showrepl` showed
   successful inbound replication from DC02 on all five partitions. The connection tests
   also passed (DNS, RPC port 135, `nltest`, `dcdiag /test:connectivity`). I did not confirm
   the cause. The likely explanation is that the replication connections were still being
   built.
7. **A stale DHCP failover relationship survived on DC02.** `Get-DhcpServerv4Failover`
   showed `DC01-DC02-Failover` in state `PartnerDown`, pointing at the old DC01. The rebuilt
   DC01 had no DHCP role, so querying it returned error `DHCP 20005`. I installed and
   authorized DHCP on DC01, removed the old relationship (the removal warned it could not
   delete it on the partner, which no longer existed), and recreated it with the wizard. The
   state returned to `Normal`, and option 6 was correct on both servers. The recreated
   relationship has `AutoStateTransition` set to False, unlike the original.

## Verification
```text
Source DSA          largest delta    fails/total %%   error
 DC02                      01m:37s    0 /   5    0

Destination DSA     largest delta    fails/total %%   error
 DC01                      01m:37s    0 /   5    0
```
- `Get-ADDomainController` listed DC01 and DC02, both Global Catalogs, in site `HQ-Lab`.
- `repadmin /showrepl` on DC01 listed DC02 as an inbound neighbor for all five partitions, each
  "was successful."
- DHCP failover state `Normal`, with option 6 listing both DNS servers on DC01 and DC02.
- The users and OUs were present on the rebuilt DC01, showing the directory came back by
  replication. 
- FSMO roles: left on DC02

## Evidence
I did not capture screenshots during the break, seize, and cleanup steps because I was
working against the clock. The evidence for those steps is the command output above and my
recorded times. I reocrded the timestamp of my cmds by copy pasting them into Claude AI to keep a runing tally of every cmd i input.

## What I would do differently
- Delete old checkpoints on a domain controller as soon as a second DC exists. They kept
  files locked after the VM was deleted.
- Check DHCP scope options on both partners before any drill that removes one of them.
- Keep the Schema Admins and Enterprise Admins step ready, since the two forest-wide roles
  need them.
- Take screenshots at each step, even if it costs a minute.

## What I learned
- The domain, DNS, and DHCP kept working on one DC, but only because the second DC and the
  DHCP failover were configured correctly beforehand.
- `repadmin /replsummary` and `/showrepl` showed replication was healthy even while
  `/syncall` printed errors, so I read the state directly instead of trusting one message.
- Losing a DC leaves loose ends that nothing warns you about: stale DNS records, a stale
  failover relationship, and DNS client lists that still point at the dead server.

## Related Files
[DC failure runbook](../runbooks/phase11/replace-failed-domain-controller.md)