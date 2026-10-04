# Printer Plan

Seven shared print queues on PS01. The printer IPs are fake, since there is no
physical hardware, and jobs sit in the queue.

| Queue name      | Department  | Printer IP (fake, static) | Who can print         |
| `IT-PRN-01`     | IT          | `10.10.10.50`             | `DL-Print-IT`         |
| `HR-PRN-01`     | HR          | `10.10.10.51`             | `DL-Print-HR`         |
| `FIN-PRN-01`    | Finance     | `10.10.10.52`             | `DL-Print-Finance`    |
| `SAL-PRN-01`    | Sales       | `10.10.10.53`             | `DL-Print-Sales`      |
| `MKT-PRN-01`    | Marketing   | `10.10.10.54`             | `DL-Print-Marketing`  |
| `OPS-PRN-01`    | Operations  | `10.10.10.55`             | `DL-Print-Operations` |
| `COMMON-PRN-01` | Everyone    | `10.10.10.56`             | `DL-Print-Common`     |

Each `DL-Print-<Dept>` group contains the matching `GG-<Dept>` group, and
`DL-Print-Common` contains `GG-All-Staff`, so printer access follows the same
AGDLP pattern as the file shares.