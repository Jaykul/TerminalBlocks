function Reset-LastExitCode {
    [CmdletBinding()]
    param()
    $global:LASTEXITCODE = [PoshCode.TerminalBlock]::LastExitCode
}
