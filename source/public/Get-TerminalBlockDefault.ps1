function Get-TerminalBlockDefault {
    [OutputType([hashtable])]
    [CmdletBinding()]
    param()
    [PSCustomObject]@{
        PSTypeName                    = "PoshCode.TerminalBlocks.Defaults"
        FirstAutomaticBackgroundColor = [PoshCode.TerminalBlocks.Block]::FirstAutomaticBackgroundColor
        AutomaticBackgroundHueStep = [PoshCode.TerminalBlocks.Block]::AutomaticBackgroundHueStep
        DefaultCaps = [PoshCode.TerminalBlocks.Block]::DefaultCaps
        DefaultSeparator = [PoshCode.TerminalBlocks.Block]::DefaultSeparator
    }
}
