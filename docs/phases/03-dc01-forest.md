# Phase 3: Creating a Domain Controller and Forest

**Date:** 10-3-2026
**Time spent:** 1 hour
**Status:** Done
**Branch:** phase/03-dc01-forest

## Objective
- Create the first domain controller running Active Dirtectory, DNS, and host a domain.

## Prerequisites
- Create VM for DC01

## Steps performed
1. Created a checkpoint of the DC pre promotion in the event there were issues or errors
2. Named and addressed the server
3. Installed AD and DNS roles
   - ![Add roles](../images/phase03/03-Add-AD-DNS-Roles.png)
4. Promoted to server domain controller
   - ![Server Promotion](../images/phase03/04-Server-Promotion.png)
5. Add DNS forwarders
   - Enables lab machines to reach the internet
   - Add-DnsServerForwarder -IPAddress 1.1.1.1 8.8.8.8
6. Creat reverse lookup zone
   - Enables conversion from IP to name
   - Add-DnsServerPrimaryZone -NetworkId "10.10.10.0/24" -ReplicationScope Domain
7. Set DC01 as time authority for the domain
   - w32tm /config /manualpeerlist:"time.windows.com,0x9" /syncfromflags:manual /reliable:yes /update
   - Restart-Service w32time
   - w32tm /query /status


## Verification
1. Listed Services in powershell to confirm NTDS, DNS, NetLogon, and KDC were all running
   -  Get-Service NTDS, DNS, Netlogon, KDC | Select-Object Name, Status
2. Ran nslookup for both IP and hostname to confirm DNS functionality
3. dcdiag
   - dcdiag /v | Out-File C:\dcdiag-dc01.txt


![Verification output](../images/phaseNN/NN-verification.png)

## Problems encountered
1. Failed markers in dcdiag output
   - DFSREvent failure
      - [Troubleshooting](../troubleshooting/phase03/03-DFSR-failure.md)
      - ![DFSR Resolved](../images/phase03/Verification-DFSR-Fixed.png)
   - SystemLog failure
      - [Troubleshooting](../troubleshooting/phase03/03-SystemLog-failure.md)
   - Time failure
      - [Troubleshooting](../troubleshooting/phase03/03-Time-failure.md)

## What I learned
1. Errors are expected after the initial promotion of a DC, and are not cause for immediate concern.
2. I did not reaslize that the DC needed to have reverse DNS setup via cmd line. I assumed it was all handles by same feature, but i now know that forward and reverse DNS are separate functions.
