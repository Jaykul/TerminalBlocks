function Get-TerminalBlockDefault {
    [OutputType([hashtable])]
    [CmdletBinding()]
    param()
    [PSCustomObject]@{
        FirstAutomaticBackgroundColor = [PoshCode.TerminalBlock]::FirstAutomaticBackgroundColor
        AutomaticBackgroundHueStep = [PoshCode.TerminalBlock]::AutomaticBackgroundHueStep
        DefaultCaps = [PoshCode.TerminalBlock]::DefaultCaps
        DefaultSeparator = [PoshCode.TerminalBlock]::DefaultSeparator
    }
}
