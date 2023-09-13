#requires -Module TerminalBlocks
param(
    [PoshCode.Pansies.RgbColor]$StartColor = "DeepSkyBlue",
    [PoshCode.Pansies.RgbColor]$EndColor = "SlateBlue4"
)

# We need a bunch of colors for the prompt...
$Colors = Get-Gradient $StartColor $EndColor -steps 6

# Clearn out the Caps, in case you used the powerline example
[PoshCode.TerminalBlock]::DefaultCaps = '', ' '

# With terminal blocks, you generate blocks up front, and then just ToString them in your prompt function:
$global:Prompt = @(
    Show-LastExitCode -Fg PaleVioletRed1
    Show-ElapsedTime -Autoformat -Fg Gray80 -Prefix "&hourglassdone;"
    New-TerminalBlock -Newline

    Show-Date -Format "h\:mm" -Fg Yellow2 -Prefix "&watch;"
    Show-LocationStack -Prefix "&filefolder;" -RepeatCharacter "&pushpin;"
    Show-NestedPromptLevel -RepeatCharacter "&Gear;" -Postfix " " -Fg Tan1
    Show-Path -Prefix "&openfilefolder;" -HomeString "&House;" -Separator '' -Fg $Colors[3] -Depth 2 -AsUrl
    Show-PoshGitStatus -Prefix "[" -Postfix "]"
    New-TerminalBlock -Newline

    Show-HistoryId -Fg DeepSkyBlue <# -Prefix "&nf-fa-hashtag;" #> -Postfix " PS>"
)
# Make the PSReadLine continuation prompt match the last line of the prompt
Set-PSReadLineOption -ContinuationPrompt '> ' -Colors @{ ContinuationPrompt = $StartColor.ToVt() }

function global:Prompt {
    -join $Prompt

    # Change the background of the whole last section of the prompt:
    Set-PSReadLineOption -PromptText @(
        Show-HistoryId -Fg DeepSkyBlue -Postfix " PS>"
        Show-HistoryId -Fg Tomato -Postfix " PS>"
    )

    Reset-LastExitCode
}
