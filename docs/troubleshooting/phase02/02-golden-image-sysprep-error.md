Error
- Sysprep was not able to validate your windows installation

Steps taken
- looked at setupact log file to determine root cause
- found line 
    "2026-10-02 21:31:47, Error                 SYSPRP Package Microsoft.MicrosoftEdge.Stable_154.0.4258.48_neutral__8wekyb3d8bbwe was installed for a user, but not provisioned for all users. This package will not function properly in the sysprep image."
- reseearched error and determined it best to remove package entirely
    - Get-AppxPackage -Allusers *MicrosoftEdge.Stable*
    - Get-AppxPackage -AllUsers *MicrosoftEdge.Stable* | Remove-AppxPackage -AllUsers