# Phase 04: dc02-dhcp

**Date:** 10-3-2026
**Time spent:** 2 hours
**Status:** Done
**Branch:** 04-dc02-dhcp

## Objective
Redundancy. Secondary DC that handles DHCP, DNS, and Logons when DC01 goes down.

## Prerequisites
- DC01 configured

## Steps performed
1. Set up DHCP on DC01 using a script
   - Script
      - Install DHCP server
      - Creates security groups DHCP Administrators and DHCP Users
      - Restarts DHCP
      - Registers DC01 to enable DHCP handouts
      - Creates address pools
2. Set up DC02
   - Network
   - Confirm it can see Meridian Domain and promote 
3. DNS setup
   - Set each DC to primary DNS of the other, and secondary as itself.
   - Add DNS forwarders to DC02
4. Set up DHCP failover on DC02
   - Install DHCP Server
   - Commit
   - Set failover
      - ![Failover set](../images/phase04/05-DHCP-Failover-Set.png)
         *Failover Set*

## Verification
1. Sonfirmed DHCP setup script worked
   - Get-DhcpServerInDC
   - Get-DhcpServerv4Scope
   - Get-DhcpServerv4OptionValue -ScopeId 10.10.10.0
2. Confirm replication works
   - Canary test
      - Create an AD object on DC01 and confirm it appears on DC02
      - ![Replicaiton Success](../images/phase04/04-Replication-Success.png)
         *Object appears in both DC.*
3. Confirm DHCP failover set
   -![Verification](../images/phase04/Verification-DHCP-Failover.png)
   *Verification* 
4. Failover Test
   - Shut down DC01
   - nltest /dsgetdc:corp.meridian.lab
      - returns DC02, good sign!
   - Create and delete a user on DC02 to see if AD can still be written to
      ![Verification](../images/phase04/Verification-Failover-Test-Success.png)

## Problems encountered
1.  Setup script for DHCP encountered an error when setting DNS for the DC, as it could not reach DC02.
   - Solution:
      - Set manually to avoid this issue, then set up DC02.
      - Alternative, set up DC02 before running script.

## Related files
- Scripts: [DHCP Setup](../../scripts/04-configure-dhcp.ps1.ps1)
