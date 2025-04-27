#requires -Module Sixel, TerminalBlocks
[CmdletBinding()]
param(
    [PoshCode.Pansies.RgbColor]$StartColor = "DarkOrange",

    [Alias("Step")]
    [int]$HueStep = 5,

    # The image to show (using ConvertTo-Sixel)
    $Image = "logo.png",

    # Number of columns the image is wide (we add 2 columns of padding before writing information))
    $Columns = 55,

    # Number of lines the image is tall
    $Lines = 21
)

$Offset = [PoshCode.TerminalPosition]@{ Col = $Columns + 2 }
Set-TerminalBlockDefault -BackgroundColor $StartColor -HueStep $HueStep -Caps "$Offset", "" -Separator "`n$Offset"

$Padding = ' ' * 100
$Info = @(
    # Show-AzureContext -Prefix 'AzureContext: '
    # Show-CondaContext -Prefix 'CondaContext: '
    # Show-ExoNamespace -Prefix 'ExoNamespace: '
    Show-CPUName -Prefix '  CPU: ' -Postfix $Padding -MaxLength 50
    Show-GPUName -Prefix '  GPU: ' -Postfix $Padding -MaxLength 50
    Show-Date -Prefix '  Date: ' -Postfix $Padding -MaxLength 50
    Show-DockerContext -Prefix '  Docker: ' -Postfix $Padding -MaxLength 50
    # Show-ElapsedTime -Prefix 'ElapsedTime: '
    # Show-ErrorCount -Prefix 'Errors: '
    # Show-HistoryId -Prefix 'HistoryId: '
    Show-HostName -Prefix '  HostName: ' -Postfix $Padding -MaxLength 50
    # Show-JobOutput -Prefix 'JobOutput: '
    Show-KubeContext -Prefix '  Cluster: ' -Postfix $Padding -MaxLength 50
    # Show-LastExitCode -Prefix 'LastExitCode: '
    # Show-LocationStack -Prefix 'LocationStack: '
    Show-Memory -Prefix '  Memory: ' -Separator " / " -ShowUsed -Postfix $Padding -MaxLength 50
    # Show-NestedPromptLevel -Prefix 'NestedPromptLevel: '
    Show-OSTheme -Prefix '  Theme: ' -Postfix $Padding -MaxLength 50
    # Show-Path -Prefix 'Path: '
    # Show-PoshGitStatus -Prefix 'PoshGitStatus: '
    Show-UserName -Prefix '  UserName: ' -Postfix $Padding -MaxLength 50
    Show-Version System -Prefix "  OS: " -Postfix $Padding -MaxLength 50
    Show-Version Kernel -Prefix "  Kernel: " -Postfix $Padding -MaxLength 50
    Show-Version .NET -Prefix "  DotNet: " -Postfix $Padding -MaxLength 50
    Show-Version PowerShell -Prefix "  PowerShell: " -Postfix $Padding -MaxLength 50
    Show-Weather -Prefix '  Weather: ' -Postfix $Padding -MaxLength 50
    ""
    $Offset.Col += "      Palette: ".Length
    Show-Palette -Prefix '      Palette: ' -Background Gray13 -Separator "`n$Offset"
)



"`e[s"
if ($Info.Count -gt $LINES) {
    # THE Info is longer than the picture, let's center it by putting the picture down
    [int]$padding = ($Info.Count - $LINES) / 2
    "`e[${padding}E"

}
ConvertTo-Sixel $(
    if (Test-Path $Image) { $Image }
    elseif (Test-Path (Join-Path $Home $Image)) { Join-Path ~ $Image }
    elseif (Test-Path (Join-Path $PSScriptRoot $Image)) { Join-Path $PSScriptRoot $Image }
)
"`e[u"

if ($Info.Count -lt $LINES) {
    # THE Info is shorter than the picture, let's center it by starting lower
    [int]$padding = ($LINES - $Info.Count) / 2
    "`e[${padding}E"
}

$Info | % ToString

# move cursor back to the bottom and print 2 newlines
if ($Info.Count -lt $LINES) {
    "`e[${padding}E"
}
"`e[?25h"
