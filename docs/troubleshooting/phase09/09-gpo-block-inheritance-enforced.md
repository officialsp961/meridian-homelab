# Problem: Block Inheritance stops a GPO from applying, and Enforced overrides it

> **Planned drill: I broke this on purpose** to see how it fails and how to recover from it.
> This was not an unplanned production incident.

## What I did
Enabled **Block Inheritance** on `OU=Finance`, then ran `gpupdate /force` on a Finance
client.

## Symptom
Lockscreen and wallpaper no longer applied.

## Cause
Block Inheritance prevents policies linked above an OU from flowing down to it.

## Fix
Right-clicked the `Branding` GPO link and chose **Enforced**, so it applies even where
inheritance is blocked. Confirmed this resolved the issue, then removed Block
Inheritance from Finance to restore the normal state.
