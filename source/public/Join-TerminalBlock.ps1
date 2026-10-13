function Join-TerminalBlock {
    [CmdletBinding(DefaultParameterSetName = "Custom")]
    param(
        # The blocks to join together to this line
        [Parameter(Mandatory, Position = 0)]
        [PoshCode.TerminalBlocks.Block[]]$Block,

        # The background color behind the line of blocks
        [Alias("BgColor", "DefaultColor")]
        [PoshCode.Pansies.RgbColor]$BackgroundColor = [PoshCode.TerminalBlocks.Block]::DefaultColor,

        # The start color for a background color gradient, e.g.: "#ed4559"
        [Parameter(Mandatory, ParameterSetName = "Gradient")]
        [Parameter(Mandatory, ParameterSetName = "ColorWheel")]
        [PoshCode.Pansies.RgbColor]$StartColor,

        # The end color for a background color gradient, e.g.: "#352675"
        [Parameter(Mandatory, ParameterSetName = "Gradient")]
        [PoshCode.Pansies.RgbColor]$EndColor,

        # The Hue step color for a background color wheel, e.g.: 8
        [Parameter(ParameterSetName = "ColorWheel")]
        [int]$HueStep = 50,

        # The change in brightness step color for a background color wheel, e.g.: 8
        [Parameter(ParameterSetName = "ColorWheel")]
        [int]$BrightStep = 4,

        # The default caps for this line of blocks
        [PoshCode.TerminalBlocks.Caps]$Caps
    )

    # We want to weave background and foreground colors on the caps
    # Some TerminalBlocks have conditional output, so only look at the ones that actually produce output
    $Line = $Block.Where{ $_.Invoke($MyInvocation.HistoryId) }
    # TerminalBlocks tracks the (previous) last exit code, put it back
    Reset-LastExitCode
    if (!$Line) {
        return
    }

    $Gradient = if ($PSCmdlet.ParameterSetName -eq "ColorWheel") {
        Get-ColorWheel -Passthru -StartColor $StartColor -HueStep $HueStep -BrightStep $BrightStep -Count ($Line.Count - 1)
    } elseif ($PSCmdlet.ParameterSetName -eq "Gradient") {
        Get-Gradient -StartColor $StartColor -EndColor $EndColor -Count $Line.Count
    }

    -join @(
        if ($Gradient) {
            for ($i = 0; $i -lt $Line.Count; $i++) {
                $Line[$i].Caps = $Caps
                $Line[$i].BackgroundColor = $Gradient[$i]
                $Line[$i].ForegroundColor = $Gradient[$i].GetComplement($true, $true)
                $Prev = ($i -eq 0 ? $BackgroundColor : $Gradient[$i - 1]) ?? [PoshCode.TerminalBlocks.Block]::DefaultColor
                $Next = (($i + 1) -lt $Gradient.Count ? $Gradient[$i + 1] : $BackgroundColor) ?? [PoshCode.TerminalBlocks.Block]::DefaultColor
                $Line[$i].ToString($Prev, $Next, $MyInvocation.HistoryId)
            }
        } else {
            for ($i = 0; $i -lt $Line.Count; $i++) {
                $Line[$i].Caps = $Caps
                $Prev = ($i -eq 0 ? $BackgroundColor : $Line[$i - 1].BackgroundColor) ?? [PoshCode.TerminalBlocks.Block]::DefaultColor
                $Next = (($i + 1) -lt $Line.Count ? $Line[$i + 1].BackgroundColor : $BackgroundColor) ?? [PoshCode.TerminalBlocks.Block]::DefaultColor
                $Line[$i].ToString($Prev, $Next, $MyInvocation.HistoryId)
            }
        }
    )
}
