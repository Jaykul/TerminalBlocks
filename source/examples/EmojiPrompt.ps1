#requires -Module TerminalBlocks
param(
    [PoshCode.Pansies.RgbColor]$PathColor = "DeepSkyBlue",
    [PoshCode.Pansies.RgbColor]$IdColor = "SlateBlue",
    [PoshCode.Pansies.RgbColor]$PromptColor = "Gray30"
)

# Clean out the Caps, in case you used the powerline example
# Disable automatic background colors because we don't want the background effect
Set-TerminalBlockDefault -Caps '', ' ' -FirstAutomaticBackgroundColor $null

# With terminal blocks, you generate blocks up front, and then just ToString them in your prompt function:
$global:Prompt = @(
    Show-LastExitCode -Fg PaleVioletRed1
    Show-ElapsedTime -Autoformat -Fg Gray80 -Prefix "⌛"
    Show-Newline

    Show-Date -Format "h\:mm" -Fg Yellow2 -Prefix "⌚"
    Show-LocationStack -Prefix "📁" -RepeatCharacter "📌"
    Show-NestedPromptLevel -RepeatCharacter "⚙️" -Postfix " " -Fg Tan1
    # Note -AsUrl makes the path clickable in many terminals (like Windows Terminal)
    Show-Path -Prefix "📂" -HomeString "🏠" -Separator '' -Fg $PathColor -Depth 2 -AsUrl
    Show-PoshGitStatus -Prefix "[" -Postfix "]"
    Show-Newline

    Show-HistoryId -Fg $IdColor -Prefix "#"
    Show-Space -Content '❯' -Fg $PromptColor
)

# Make the PSReadLine continuation prompt match the last line of the prompt
Set-PSReadLineOption -ContinuationPrompt '❯' -Colors @{ ContinuationPrompt = $PromptColor.ToVt() }

function global:Prompt {
    -join $Prompt

    # Customize what PS ReadLine redraws when there's an "error"
    Set-PSReadLineOption -PromptText @(
        # Normal condition, put back what was there
        -join @(
            Show-HistoryId -Fg $Prompt[-2].ForegroundColor -Prefix "#"
            Show-Space -Content '❯' -Fg $Prompt[-1].ForegroundColor
        )
        # Error condition, change the colors to Tomato
        -join @(
            Show-HistoryId -Fg Tomato -Prefix "#"
            Show-Space -Content '❯' -Fg Tomato
        )
    )

    Reset-LastExitCode
}
