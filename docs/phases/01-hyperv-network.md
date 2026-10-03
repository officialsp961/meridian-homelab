# Phase N: Title

**Date:** YYYY-MM-DD
**Time spent:** X hours
**Status:** In progress / Done
**Branch:** phase/NN-name

## Objective
- Phase 1 is all planning and setup. This was crucial to avoid hiccups later and ensure standardized setups with multiple servers and clients.

## Prerequisites
- None fo rhtis phase, but that will change very quickly.

## Steps performed
1. Enabled hyper-v.
2. Set up an internal virtual switch with NAT enabled to ensure clients and hosts can communicate properly.
  

## Verification
1. Ran Get-VMSwitch to show th virtual switch exsists
2. Ran Get-NetNat to show the network is set properly, including IP scheme and prefix

 ![Virtual switch setup confirmation](../images/phaseNN/04-get-netnat-labnat.png)

## Problems encountered
- None yet!

## What I learned
So far this is pretty basic stuff, so nothing major learned other than the sepecific cmds to list and create the virtual switch.
