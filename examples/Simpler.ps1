#requires -Module TerminalBlocks
[PoshCode.TerminalBlock]::DefaultCap = " "
[PoshCode.TerminalBlock]::DefaultSeparator = " "


[PoshCode.TerminalBlock[]]$global:Blocks = @(
    # You can use -Cap "`n" instead of a newline block to add a newline only IF this block is output
    Block { Write-VcsStatus } -Foreground '#FFFFFF' -Cap "`n"

    Block { $MyInvocation.HistoryId } -Foreground 'White'
    Block { Show-Path -HomeString "&House;" -Length 35 } -Foreground 'SteelBlue1'

    # Use a short time format and a clock prefix (I don't need the EXACT time in my prompt)
    # Because all of these are right-aligned, the first one is the furthest to the right
    Block { Show-Date -Format "h\:mm" -Prefix "🕒" } -Foreground '#FFFFFF' -Alignment 'Right'
    Block { Show-ElapsedTime -Autoformat } -Foreground '#FFFFFF' -Alignment 'Right'
    Block { Show-LastExitCode } -ErrorBackgroundColor '#8B2252' -Separator ' ' -Alignment Right

    # Since this isn't right aligned, it starts a new line
    # So the in-line prompt is just this one character:
    Block '❯' -Foreground '#AEAEAE'
)

Write-TerminalBlock #Prompt
