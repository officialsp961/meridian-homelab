## Error
1. DFSR failed on dcdiag output

## Steps taken
1. Research
    - Likely fine as Sysvol and Netlogons both passed.
    - This is the only DC, so there is nothing to replicate at this time.
    - Found and ran Get-WinEvent -LogName "DFS Replication" -MaxEvents 15
        - Output confirmed this error was from the promotion, and DFSR recovered itself
