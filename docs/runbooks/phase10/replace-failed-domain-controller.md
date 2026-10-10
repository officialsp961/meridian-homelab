# Runbook: Replace a failed domain controller

**Applies to:** corp.meridian.lab (DC01, DC02)
**Last reviewed:** 2026-10-10
**Basis:** A planned drill in which DC01 was destroyed and rebuilt. See the
[drill write-up](../troubleshooting/phase11/11-dc01-total-loss-drill.md).

## When to use this
A domain controller has died and will not come back. The domain keeps working on the
surviving DC, so this is urgent but not an outage.

**Assumes** DHCP, DNS, and replication were healthy when the DC failed.

**Never power the failed DC back onto the network** after you start step 3. A DC returning
with stale data can corrupt replication.

**Drill benchmark (lab):** replacement DC signed in at 33 minutes, replicating at about 43,
full redundancy at about 55.

## Step 1: Confirm the failure and record the time
1. Confirm the DC is really gone (off, deleted, or not answering).
2. Note the start time, and keep notes as you go.

## Step 2: Confirm the domain still works
On the surviving DC (DC02 in the drill):
1. `nltest /dsgetdc:corp.meridian.lab` returns the survivor.
2. **Active Directory Users and Computers** opens and shows the OUs.
3. On a client: `ipconfig /release`, `ipconfig /renew`, then `nslookup corp.meridian.lab`.
4. A domain user can sign in and open a file share.

## Step 3: Seize the FSMO roles
Check who holds them: `netdom query fsmo`. If the failed DC holds roles, seize them.
**This is the one step with no GUI.**

1. Sign in on the survivor as **`MERIDIAN\Administrator`**. It is in Schema Admins and
   Enterprise Admins, which the forest-wide roles need. Check:
   `whoami /groups | findstr /i "Schema Enterprise"`.
2. Run:
```powershell
   Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole PDCEmulator, RIDMaster, InfrastructureMaster, SchemaMaster, DomainNamingMaster -Force
   netdom query fsmo
```
3. All five roles should name the survivor. It can take several minutes while the dead DC
   times out, so do not cancel it early.

**Hurdle:** with only a Domain Admin account, three roles move and the Schema master and
Domain naming master fail with "Access is denied." Re-run those two as the built-in
Administrator. In the drill this cost about 10 minutes. Do not add Domain Admins to Schema
Admins or Enterprise Admins.

## Step 4: Clean up the failed DC's records (GUI, on the survivor)
1. **Active Directory Users and Computers:** open **Domain Controllers**, right-click the
   failed DC, **Delete**, and choose **This Domain Controller is permanently offline...**.
2. **DNS Manager:** in `corp.meridian.lab` and `_msdcs.corp.meridian.lab`, delete the failed
   DC's host (A) record, its NS records, and any `_ldap` or `_kerberos` SRV records naming
   it. Check the reverse zone for its PTR record.
3. **Active Directory Sites and Services:** under **Sites, HQ-Lab, Servers**, delete the
   failed DC if it is listed.
4. **Fix the survivor's DNS client list.** It still lists the dead DC first, which makes
   every lookup wait for a timeout. Point the survivor at itself for now:
```powershell
   Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1
```
5. **Check:** `nslookup -type=SRV _ldap._tcp.dc._msdcs.corp.meridian.lab 127.0.0.1` lists only
   the survivor.

## Step 5: Remove the stale DHCP failover relationship
On the survivor's DHCP console, right-click the scope and choose **Deconfigure Failover**. If
that fails because the partner is unreachable:
```powershell
Get-DhcpServerv4Failover -ComputerName DC02
Remove-DhcpServerv4Failover -ComputerName DC02 -Name "DC01-DC02-Failover" -Force
```
A warning that it could not delete the relationship on the partner is expected. Confirm the
scope is still **Active**.

## Step 7: Build and promote the replacement

### 7a. Create the replacement VM (on the Hyper-V host)
The script `scripts/emergency-dc-rebuild.ps1` creates the replacement VM from the golden image
on a differencing disk and starts it. **You must give it the name of the DC that failed.** The
script will not run without a name, and no editing of the file is needed.

1. Open **Windows PowerShell as Administrator** on the host.
2. Run the script with the failed DC's exact name:
```powershell
   cd D:\meridian-homelab
   .\scripts\emergency-dc-rebuild.ps1 -Name "DC02"
```
   If you leave `-Name` off, PowerShell prompts `Name:`. Type the exact name of the DC that
   failed. A blank answer is rejected.
3. Check it was created and started:
```powershell
   Get-VM -Name "DC02"
```
4. If the script stops with an error, read it:
   - **`Template not found`:** the golden image is missing. See the prerequisite below.
   - **`A VM named ... already exists`:** the failed VM is still registered in Hyper-V, so finish
     Step 6 first.
5. If an old disk file for that name is still present (for example, locked), the script prints a
   warning and **uses a new disk name** (`<name>-new.vhdx`) automatically.

The script creates and starts the VM only. It does not name the server, set an IP address, or
make it a domain controller. That is 7b onward.

### 7b. First boot and network (inside the new server)
1. Finish first-boot setup and set the administrator password.
2. **Rename the server** to the name of the failed DC and restart.
3. Set the static IP of the failed DC and the
   gateway, with **DNS pointing at the surviving DC only**.
4. Check it can find the domain: `nslookup corp.meridian.lab` returns the survivor.

### 7c. Promote it
1. **Add Roles and Features:** Active Directory Domain Services and DNS.
2. **Promote this server to a domain controller:** **Add a domain controller to an existing
   domain**, domain `corp.meridian.lab`, enter `MERIDIAN\Administrator`, keep DNS and Global
   Catalog ticked, set a new DSRM password, and **Replicate from** the survivor. Install and let
   it restart.
3. **Wait about 10 minutes** after the restart before judging results. Services are still
   starting, and early checks give misleading errors.

## Step 8: Verify the replacement
1. `Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, IsGlobalCatalog, Site`
   lists both DCs.
2. `repadmin /replsummary` shows 0 failures, and `repadmin /showrepl` shows "was successful"
   for the survivor on all five partitions.
3. **Expect noise.** `dcdiag` may fail **DFSREvent** and **SystemLog** right after promotion.
   These are timing warnings and they clear. Look for a newer DFS Replication event 4602.
4. **`repadmin /syncall /AdeP` may say "topology incomplete"** for a while even though
   replication is healthy. Trust `replsummary` and `showrepl`. Run `repadmin /kcc` on both
   DCs, wait a few minutes, and retry. If it persists, test with a canary: create an OU on
   one DC, confirm it appears on the other, then delete it.
5. **Check the data came back:** OUs and users are present on the new DC in ADUC.

## Step 9: Restore redundancy
1. **DNS client order:** partner first, itself second, on each DC.
   - New DC: `Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.11,127.0.0.1`
   - Survivor: `Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10,127.0.0.1`
2. **DHCP:** on the new DC, install **DHCP Server** and run **Complete DHCP configuration**
   (authorize it). On the survivor, right-click the scope, **Configure Failover**, choose the
   new DC as partner, load balance 50/50, with message authentication. Confirm
   `Get-DhcpServerv4Failover` shows `State: Normal`.
3. **FSMO roles:** leave them on the survivor, or move them back with **Operations Masters**
   in ADUC. Record which, and check `netdom query fsmo`.
4. **Check clients and servers:** a client renews and resolves DNS, a domain sign-in works,
   `nltest /dsgetdc:corp.meridian.lab` returns a DC, and shares open through the DFS path.
5. Record the finish time.

## After the incident
- Write down the timeline and anything that differed from this runbook.
- Take a fresh system state backup of both DCs.
- Update this runbook with anything that went differently.