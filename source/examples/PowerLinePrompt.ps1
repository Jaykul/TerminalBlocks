#requires -Module TerminalBlocks
param(
    [PoshCode.Pansies.RgbColor]$StartColor = "DeepSkyBlue",
    [PoshCode.Pansies.RgbColor]$EndColor = "SlateBlue4"
)

# We need a bunch of colors for the prompt...
$Colors = Get-Gradient $StartColor $EndColor -steps 8 | Get-Complement -Passthru -BlackAndWhite

# This is the main thing that makes it PowerLine
[PoshCode.TerminalBlock]::DefaultCaps = '', [char]0xe0b0

# Hhere's the prompt:
$global:Prompt = @(
    Show-ElapsedTime -Autoformat -Bg White -Fg Black -Prefix "" -Caps '', ''
    New-TerminalBlock -Newline

    Show-Date -Format "h\:mm" -Bg $Colors[2] -Fg $Colors[3]
    Show-LocationStack -Bg $Colors[4] -Fg $Colors[5]
    Show-NestedPromptLevel -RepeatCharacter "&Gear;" -Postfix " " -Bg $Colors[6] -Fg $Colors[7]

    New-TerminalBlock -Spacer -Bg $Colors[10]
    Show-Path -HomeString "&House;" -Separator '' -Bg $Colors[10] -Fg $Colors[11]
    Show-PoshGitStatus -Bg $Colors[8]
    New-TerminalBlock -Newline

    Show-LastExitCode -ForegroundColor 'VioletRed1' -Caps "", "`n"

    # This is literally just a decorative chevron to match the continuation prompt
    New-TerminalBlock -Spacer -Fg White -Bg $StartColor
    New-TerminalBlock -Spacer -Fg $StartColor -Bg $Colors[14]
    Show-HistoryId -Bg $Colors[14] -Fg $Colors[15]
)
# Make the PSReadLine continuation prompt match the last line of the prompt
Set-PSReadLineOption -ContinuationPrompt █ -Colors @{ ContinuationPrompt = $StartColor.ToVt() }

function global:Prompt {
    -join $Prompt

    # We _could_ just set the -PromptText above and leave it, but that only changes the last "" of the prompt
    # This way, we're changing the background of the whole last section of the prompt:
    Set-PSReadLineOption -PromptText @(
        (([RgbColor]"DeepSkyBlue").ToVt() + ([RgbColor]"SlateBlue").ToVt($true) + "") + (Show-HistoryId -Bg SlateBlue -Fg White)
        (([RgbColor]"DeepSkyBlue").ToVt() + ([RgbColor]"Tomato").ToVt($true) + "") + (Show-HistoryId -Bg Tomato -Fg Black)
    )

    Reset-LastExitCode
}
