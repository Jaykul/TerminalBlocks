#requires -Module TerminalBlocks
[PoshCode.TerminalBlock]::DefaultCap = "`u{E0B0}", "`u{E0B2}"
[PoshCode.TerminalBlock]::DefaultSeparator = "`u{E0B1}", "`u{E0B3}"


[PoshCode.TerminalBlock[]]$global:Blocks = @(
    # Let's try a fancy bar at the top
    New-TerminalBlock { Show-Path -HomeString "&House;" } -Background 'Gray100' -Foreground 'Black'
    New-TerminalBlock -Spacer
    New-TerminalBlock { Write-VcsStatus }                 -Background 'Gray72'

    New-TerminalBlock { Show-Date }                       -Background 'Gray23' -Alignment 'Right'
    New-TerminalBlock -Spacer -Alignment 'Right'
    New-TerminalBlock { Show-ElapsedTime -Autoformat }    -Background 'Gray47' -Alignment 'Right'

    New-TerminalBlock { $MyInvocation.HistoryId }         -Background 'SteelBlue1' -ErrorBackgroundColor '#8B2252'
)
