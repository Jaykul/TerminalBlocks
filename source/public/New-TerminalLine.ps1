function New-TerminalLine {
    [CmdletBinding(DefaultParameterSetName = "Custom")]
    param(
        [Alias("Left")]
        [PoshCode.TerminalBlocks.Block[]]$LeftBlock,
        [Alias("Right")]
        [PoshCode.TerminalBlocks.Block[]]$RightBlock,
        [Alias("Center")]
        [PoshCode.TerminalBlocks.Block[]]$CenterBlock,
        [PoshCode.TerminalBlocks.Caps]$LeftCaps = ("", ${nf:pl-left_hard_divider}),
        [PoshCode.TerminalBlocks.Caps]$RightCaps = (${nf:pl-right_hard_divider}, ""),
        [PoshCode.Pansies.RgbColor[]]$Color,
        [Alias("BgColor", "DefaultColor")]
        [PoshCode.Pansies.RgbColor]$BackgroundColor = [PoshCode.TerminalBlocks.Block]::DefaultColor
    )
    $Segments = ($LeftBlock ? 1 : 0) + ($CenterBlock ? 1 : 0) + ($RightBlock ? 1 : 0)
    Write-Debug "Color.Count: $($Color.Count), Segments: $Segments"
    $Blocks = if ($Color.Count -ge $Segments * 2) {
        if ($LeftBlock) {
            $StartColor, $EndColor, $Color = $Color
            $param = @{ Block = $LeftBlock; StartColor = $StartColor; EndColor = $EndColor; BackgroundColor = $BackgroundColor; Caps = $LeftCaps }
            Join-TerminalBlock @param
        }
        if ($CenterBlock) {
            $StartColor, $EndColor, $Color = $Color
            $param = @{ Block = $CenterBlock; StartColor = $StartColor; EndColor = $EndColor; BackgroundColor = $BackgroundColor }
            Join-TerminalBlock @param
        }
        if ($RightBlock) {
            $StartColor, $EndColor, $Color = $Color
            $param = @{ Block = $RightBlock; StartColor = $StartColor; EndColor = $EndColor; BackgroundColor = $BackgroundColor; Caps = $RightCaps }
            Join-TerminalBlock @param
        }
    } elseif ($Color.Count -ge $Segments) {
        if ($LeftBlock) {
            $StartColor, $Color = $Color
            $param = @{ Block = $LeftBlock; StartColor = $StartColor; BackgroundColor = $BackgroundColor; Caps = $LeftCaps }
            Join-TerminalBlock @param
        }
        if ($CenterBlock) {
            $StartColor, $Color = $Color
            $param = @{ Block = $CenterBlock; StartColor = $StartColor; BackgroundColor = $BackgroundColor }
            Join-TerminalBlock @param
        }
        if ($RightBlock) {
            $StartColor, $Color = $Color
            $param = @{ Block = $RightBlock; StartColor = $StartColor; BackgroundColor = $BackgroundColor; Caps = $RightCaps }
            Join-TerminalBlock @param
        }
    } else {
        if ($LeftBlock) {
            $param = @{ Block = $LeftBlock; BackgroundColor = $BackgroundColor; Caps = $LeftCaps }
            Join-TerminalBlock @param
        }
        if ($CenterBlock) {
            $param = @{ Block = $CenterBlock; BackgroundColor = $BackgroundColor }
            Join-TerminalBlock @param
        }
        if ($RightBlock) {
            $param = @{ Block = $RightBlock; BackgroundColor = $BackgroundColor; Caps = $RightCaps }
            Join-TerminalBlock @param
        }
    }

    $Width = $Host.UI.RawUI.WindowSize.Width
    $Length = ($Blocks | Measure-String | Measure-Object -Sum).Sum
    $Bg = $BackgroundColor.ToVt($true)
    $Space = $Width - $Length
    if ($Blocks.Count -eq 3) {
        $Blocks[0] + $Bg + (" " * [math]::Floor($Space / 2)) + $Blocks[1] + $Bg + (" " * [math]::Ceiling($Space / 2)) + $Blocks[2]
    } else {
        $Blocks[0] + $Bg + (" " * $Space) + $Blocks[-1]
    }
}
