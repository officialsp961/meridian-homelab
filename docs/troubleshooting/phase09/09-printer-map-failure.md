## Error
1. Printers were not mapping for users

## Steps taken
1. **Confirmed the network path.** Pinged PS01 successfully, so connectivity was not the problem.
2. **Checked whether the GPO applied.** `gpresult /r` (run from an unrestricted admin session,
   because `cmd` is blocked for restricted users) listed "HR Drive and Printers" under
   Applied Group Policy Objects. The policy reached the user.
3. **Read the full HTML report.** `gpresult /h` showed the printer item with
   **Result: Failure (Error Code: 0x80070005)**, which is Access Denied.
4. **Verified group membership.** `GG-HR` contained Jamal and `DL-Print-HR` contained
   `GG-HR`. `Get-ADPrincipalGroupMembership` returned only Domain Users, which was
   misleading, but the user's Member Of tab confirmed `GG-HR` and `GG-All-Staff`.
5. **Checked the printer's permissions.** On PS01, the Security tab for `HR-PRN-01`
   showed `DL-Print-HR` with Print allowed.
6. **Refreshed the sign-in.** Signed out and rebooted so the user's token had current
   group membership. The printer was still missing.
7. **Tested a manual connection.** Opening `\\PS01\HR-PRN-01` as Jamal worked. That
   ruled out permissions, the share, and the driver, and isolated the problem to the
   Group Policy item.

## Resolution
1. On the printer item's Common tab, enabled **Run in logged-on user's security context**, then signed out and in.
