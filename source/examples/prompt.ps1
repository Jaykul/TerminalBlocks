#requires -Module TerminalBlocks
$global:Prompt = @(
    # You can use -Cap "`n" instead of a newline block to add a newline conditional on this block being output
    Show-LastExitCode -ForegroundColor 'VioletRed1' -Caps "","`n"

    if (Get-Module posh-git) {
        Show-PoshGitStatus -BeforeStatus "" -AfterStatus "" -PathStatusSeparator "" -Caps "", "`n" # -Caps "&nf-pl-branch;", "`n" # nf-pl-branch requires a PowerLine font
    }

    Show-HistoryId -Foreground 'White'
    Show-Path -HomeString "&House;" -Foreground 'SteelBlue1' # -Separator '' # This separator requires a nerdfont

    # Use a short time format and a clock prefix (I don't need the EXACT time in my prompt)
    # Because all of these are right-aligned, the first one is the furthest to the right
    Show-Date -Format "h:mm" -Prefix "&twooclock;" -Foreground '#FFFFFF' -Alignment 'Right'
    Show-ElapsedTime -Autoformat -Prefix "&stopwatch;" -Foreground '#FFFFFF' -Alignment 'Right'

    # Since this isn't right aligned, it starts a new line
    # So the in-line prompt is just this one character:
    New-TerminalBlock '❯' -Foreground 'Gray80' -Caps ""," "
    # Update PSReadLine to match our prompt (this has no output)
    Set-PSReadLineOption -PromptText (New-Text "❯ " -Foreground 'Gray80'), (New-Text "❯ " -Foreground 'VioletRed1') -ContinuationPrompt (New-Text "❯ " -Foreground 'SteelBlue1')
)

function global:Prompt { -join$Prompt }
