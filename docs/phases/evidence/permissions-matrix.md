# Permissions Matrix

Who can access each shared folder on FS01.

- **GG-** groups are global groups that hold people.
- **DL-** groups are domain local groups that hold permissions on a resource.
- **RW** means Modify (read, create, change, delete). **RO** means read-only.

| Share | Local path on FS01 | Modify (RW) | Read-only (RO) | Quota |
| --- | --- | --- | --- | --- |
| IT | `E:\Data\Departments\IT` | `DL-IT-Share-RW` | `DL-IT-Share-RO` | 10 GB |
| HR | `E:\Data\Departments\HR` | `DL-HR-Share-RW` | `DL-HR-Share-RO` | 10 GB |
| Finance | `E:\Data\Departments\Finance` | `DL-Finance-Share-RW` | `DL-Finance-Share-RO` | 10 GB |
| Sales | `E:\Data\Departments\Sales` | `DL-Sales-Share-RW` | `DL-Sales-Share-RO` | 10 GB |
| Marketing | `E:\Data\Departments\Marketing` | `DL-Marketing-Share-RW` | `DL-Marketing-Share-RO` | 10 GB |
| Operations | `E:\Data\Departments\Operations` | `DL-Operations-Share-RW` | `DL-Operations-Share-RO` | 10 GB |
| Public | `E:\Data\Public` | `GG-IT` | `GG-All-Staff` | 5 GB |
| Branding | `E:\Data\Branding` | `GG-IT` | Authenticated Users (includes computers) | 1 GB |
| Home | `E:\Data\Home\<username>` | The user themself | Nobody else | 2 GB each |