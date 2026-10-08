# GPO Inventory

Group Policy Objects planned for `corp.meridian.lab`, where each is linked, and what it does.

| GPO name                          | Linked to                                         | Applies to          | What it does
| `Default Domain Policy` (edited)  | Domain root                                       | Everyone            | Password and lockout rules
| `ALL-Branding`                    | `Departments` OU                                  | Computers and users | Lock screen and wallpaper from the `Branding` share 
| `ALL-Security-Baseline`           | `Departments` OU                                  | Computers           | Logon banner, inactivity lock, Point and Print restrictions
| `ALL-Helpdesk-LocalAdmin`         | `Departments` OU                                  | Computers           | Adds `GG-IT-Helpdesk` to the local Administrators group on every PC
| `NONIT-USB-Block`                 | HR, Finance, Sales, Marketing, and Operations OUs | Computers           | Blocks removable storage
| `NONIT-User-Restrictions`         | HR, Finance, Sales, Marketing, and Operations OUs | Users               | No Control Panel, command prompt, or registry editor
| `ALL-DriveMap-Public`             | `Departments` OU                                  | Users               | `P:` drive to Public
| `DEPT-DriveMap-<Dept>` (6 GPOs)   | Each department OU                                | Users               | `S:` drive to the department share, plus department printers

IT is left out of the two `NONIT-` policies by linking them to the five other department OUs instead of the parent `Departments` OU.

# Password Policy

| Setting                       | Value
| Minimum password length       | 12 characters
| Complexity requirements       | Enabled
| Password history              | 24 passwords remembered
| Minimum password age          | 1 day
| Maximum password age          | 365 days
| Account lockout threshold     | 5 invalid attempts
| Lockout duration              | 15 minutes
| Lockout observation window    | 15 minutes

Applied with:

```powershell
Set-ADDefaultDomainPasswordPolicy -Identity "corp.meridian.lab" `
  -MinPasswordLength 12 -ComplexityEnabled $true -PasswordHistoryCount 24 `
  -MinPasswordAge 1.00:00:00 -MaxPasswordAge 365.00:00:00 `
  -LockoutThreshold 5 -LockoutDuration 00:15:00 -LockoutObservationWindow 00:15:00
```

## Reasons

### Length of 12 and complexity enabled
- A longer password is much harder to crack than a short complex one.
- Complexity stays on as a baseline against simple dictionary words.

### Maximum age of 365 days, not 30
- Current guidance (NIST SP 800-63B) favors long passwords and discourages
  forcing frequent changes. Frequent forced changes lead people to make small,
  predictable edits, which does not improve security.
- A yearly expiry still guarantees that old passwords do not live forever.

### History of 24 and minimum age of 1 day
- Remembering 24 passwords stops users from cycling back to an old one.
- A 1-day minimum age stops a user from changing the password several times in
  a row to get back to their original.

### Lockout after 5 attempts for 15 minutes
- Five attempts gives a legitimate user room for typos but blocks guessing attacks.
- A 15-minute automatic unlock keeps the helpdesk from handling every lockout,
  while still slowing an attacker down.
- The observation window means five failures within 15 minutes trigger the lock.
