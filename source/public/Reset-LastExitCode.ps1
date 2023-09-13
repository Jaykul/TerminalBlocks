function Reset-LastExitCode {
    $global:LASTEXITCODE = [PoshCode.TerminalBlock]::LastExitCode
}
