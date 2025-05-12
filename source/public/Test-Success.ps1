function Test-Success {
    <#
    .Synopsis
        Get a value indicating whether the last command succeeded or not
    #>
    [CmdletBinding()]
    param()
    [PoshCode.TerminalBlocks.Block]::LastSuccess
}
