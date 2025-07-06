#requires -Module TerminalBlocks
param(
    [PoshCode.Pansies.RgbColor]$StartColor = "DeepSkyBlue",
    [int]$HueStep = 8
)

Set-TerminalBlockDefault -FirstAutomaticBackgroundColor $StartColor -AutomaticBackgroundHueStep $HueStep

# This is the main thing that makes it PowerLine
[PoshCode.TerminalBlocks.Block]::DefaultCaps = '', [char]0xe0b0

# Set up whatever terminal blocks you want in your prompt ...
$global:Prompt = @(
    Show-Date -Format "h\:mm"
    Show-LocationStack
    Show-NestedPromptLevel -RepeatCharacter "&Gear;" -Postfix " "

    Show-Path -HomeString "&House;" -Separator ''
    Show-PoshGitStatus -DefaultBackgroundColor Gray30
    Show-Newline

    Show-LastExitCode -ForegroundColor 'VioletRed1' -Caps "", "`n"

    # You can add custom blocks with literally anything ... this one is just a decorative chevron
    New-TerminalBlock -Separator ' ' -Fg 'Black' -Content '' -Background $StartColor
    Show-HistoryId
)
# Make the PSReadLine continuation prompt match the last line of the prompt
Set-PSReadLineOption -ContinuationPrompt █ -Colors @{ ContinuationPrompt = $StartColor.ToVt() }




function global:Prompt {
    # For simple prompts like the emoji example, we can just: `-join $Prompt`
    # But for PowerLine, we need to weave background and foreground colors on the caps

    # Some TerminalBlocks have conditional output, so only look at the ones that actually produce output
    $ThisPrompt = @($Prompt).Where{ $_.Invoke($MyInvocation.HistoryId) }

    $Output = -join @(
        # For the caps to weave together, we need to pass the prev & next colors
        # The first block always has a default left color
        $Prev = [PoshCode.TerminalBlocks.Block]::DefaultColor
        $Next = $ThisPrompt[1].BackgroundColor ?? [PoshCode.TerminalBlocks.Block]::AutomaticColor
        $ThisPrompt[0].ToString( $Prev, $Next, $MyInvocation.HistoryId )
        for ($i = 1; $i -lt $ThisPrompt.Count - 1; $i++) {
            # For the caps to weave together, we need to pass the prev & next colors
            $Prev = $ThisPrompt[$i - 1].BackgroundColor ?? [PoshCode.TerminalBlocks.Block]::AutomaticColor
            $Next = $ThisPrompt[$i + 1].BackgroundColor ?? [PoshCode.TerminalBlocks.Block]::AutomaticColor
            $ThisPrompt[$i].ToString( $Prev, $Next, $MyInvocation.HistoryId )
        }
        # The last block always has a default right color
        $Prev = $ThisPrompt[-2].BackgroundColor ?? [PoshCode.TerminalBlocks.Block]::AutomaticColor
        $Next = [PoshCode.TerminalBlocks.Block]::DefaultColor
        $ThisPrompt[-1].ToString( $Prev, $Next, $MyInvocation.HistoryId )
    )
    $Output

    # We _could_ just set the -PromptText above and leave it, but that only changes the last "" of the prompt
    # This way, we're changing the background of the whole last section of the prompt:
    $LastLine = $Output.Split("`n")[-1]
    Set-PSReadLineOption -PromptText @(
        $LastLine
        # For error condition, just change the background and separators to Tomato
        $LastLine -replace "`e\[4[^9][\d;]*m", "`e[48;2;255;99;71m" -replace '\e\[3[^0][0-9;]*m', "`e[38;2;255;99;71m"
    )
    # TerminalBlocks tracks the (previous) last exit code, put it back
    Reset-LastExitCode
}
