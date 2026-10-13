#requires -Module Pansies, TerminalBlocks
# Set up whatever terminal blocks you want
$global:StatusLine = @{
    Left       = @(
        Show-HistoryId
        Show-HostName
        Show-UserName
        Show-AzureContext
        Show-Kubecontext

        Show-Path -HomeString "&House;" -Separator ''
        Show-PoshGitStatus -DefaultBackgroundColor Gray30
    )
    Center     = @(
        Show-LastExitCode -Caps ${nf:pl-right_hard_divider}, ${nf:pl-left_hard_divider}
    )
    Right      = @(
        Show-AzureContext
        Show-Kubecontext
        Show-DockerContext

        Show-Memory -ShowUsed
        Show-OSTheme
        Show-Weather
        Show-Date -Format "h\:mm"
    )
    Color      = "#ed4559", "#352675", 'VioletRed1', 'VioletRed1', "#352675", "#ed4559"
    Background = "Black"
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle { Write-Host -NoNewline "`e[2$~`e[1$}`e[0G$(New-TerminalLine @StatusLine)`e[0$}" }
