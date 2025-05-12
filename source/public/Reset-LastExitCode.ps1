function Reset-LastExitCode {
    [CmdletBinding()]
    param()
    $global:LASTEXITCODE = [PoshCode.TerminalBlocks.Block]::LastExitCode
}
