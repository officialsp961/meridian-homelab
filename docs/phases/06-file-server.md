# Phase 06: 06-file-server

**Date:** 10-4-2026
**Time spent:** 5 hours
**Status:** Done
**Branch:** 06-file-server

## Objective
1. Create a file sahre to accomplish the following:
    - Private share for each department
    - Public read-only share
    - Personal network share
    - a place for GPO files such as wallpaper images to live

## Prerequisites
1. Create ou
2. Create users
3. Create groups

## Steps performed
1. Planning
    - Whiteboarded share folders, the gorups that need access, the folder struture, and creating read-only to grant access as needed
    - [Whiteboard](../phases/evidence/permissions-matrix.md)
2. Set up server
    - Network
    - Name 
    - Domain Join
    - Move to proper OU
3. Set up file share
    - Bring partition online
    - Set drive letter and name
    - Install File server features
        - ![Feature Install](../images/phase06/03-file-share-setup.png)
        *Features Installed*
    - Create folder structure
        - ![Folder Struture](../images/phase06/03-folder-struture.png)
        *ls -r result*
    - Set Permissions on Folders
    - Share data folder
    - Set up home folders
        - ![Home Folders](../images/phase06/03-home-folders-working.png)
    - Set quotas on folders
        - Created a quota template
        - Applied quotas
        - ![Quotas](../images/phase06/03-Quotas.png)
    - Set file screen to filter allowed file types
    - Set shadow copy schedule to avoid data loss for users
4. Set DFS namespace
    - Doing so acccomplishes the following:
        - Masks the file share servername from users
        - Enables GPO to point to clean anemspace instead ofi the fileshare server name, meanign it can be replaced and renamed easily
        - ![Namespace](../images/phase06/04-DFS-Namespace.png)

## Verification
1. Confirmed on DC01 that FS01 appears in the servers OU
    - ![Verification](../images/phase06/Verification-FS01-domain-joined.png)
2. Confirmed home folders permissions were set properly, as these are trickier than normal folders
    - ![Verification](../images/phase06/Verification-Home-Folder-Permissions.png)
3. Confirmed file screen was working by attempting to create an exe
    - ![Verification](../images/phase06/Verificaiton-File-Screen.png)
4. Verification of shares, quotas, and DFS in powershell
    - ![Verification](../images/phase06/Verification-shares-quotas-dfs.png)
5. Verification of folder permissions
    - ![Verification](../images/phase06/Verification-folder-permissions.png)

## Problems encountered
1. Initiallly I was unable to create the home folders as the DC could not access the file location. I immediately realized this was because I had forgotten to share the folder, and resolved the issue.
2. Had an issue with customize buttons in file screen section. rebooting the server resolved the issue.

## What I Learned
1. I was unaware of the DFS namespace process. This is something I want to bring up with our admin team at work to implement to make server replacements easier.

