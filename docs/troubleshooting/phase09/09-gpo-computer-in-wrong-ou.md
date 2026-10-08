# Problem: Department GPOs stop applying when a computer is in the wrong OU

> **Planned drill: I broke this on purpose** to see how it fails and how to recover from it.
> This was not an unplanned production incident.

## What I did
Moved `CL04` from `Meridian\Departments\Finance\Computers` to the `New Computers` OU,
then ran `gpupdate /force` on the client.

## Symptom
Finance printer and drives were no longer mapped.

## Cause
GPOs apply to the OU where the object lives. `New Computers` has no department GPOs
linked, so the computer only received policies linked higher up.

## Fix
Moved the computer back to `Finance\Computers`, ran `gpupdate /force`, and restarted.
