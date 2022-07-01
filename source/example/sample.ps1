#requires -Module TerminalBlocks
[System.Collections.Generic.List[PoshCode.TerminalBlock]]$Prompt = @(
    # You can use -Cap "`n" instead of a newline block to add a newline conditional on this block being output
    New-TerminalBlock { Write-VcsStatus } -Foreground '#FFFFFF' -Cap "`n"

    Show-HistoryId -Foreground 'White'
    Show-Path -HomeString "&House;" -Separator '' -Foreground 'SteelBlue1'

    # Use a short time format and a clock prefix (I don't need the EXACT time in my prompt)
    # Because all of these are right-aligned, the first one is the furthest to the right
    Show-Date -Format "h\:mm" <# -Prefix "🕒" #> -Foreground '#FFFFFF' -Alignment 'Right'
    Show-ElapsedTime -Autoformat -Foreground '#FFFFFF' -Alignment 'Right'
    Show-LastExitCode -ErrorBackgroundColor '#8B2252' -Separator ' ' -Alignment 'Right'

    # Since this isn't right aligned, it starts a new line
    # So the in-line prompt is just this one character:
    New-TerminalBlock '❯' -Foreground '#AEAEAE'
)

function Prompt { -join$Prompt }
