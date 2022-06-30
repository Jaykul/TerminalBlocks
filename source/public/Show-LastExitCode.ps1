function Show-LastExitCode {
    <#
        .SYNOPSIS
            Show the LASTEXITCODE
        .DESCRIPTION
            Shows the exit code for native apps if the last command failed and left a LASTEXITCODE

            Can also show something for CommandNotFound or attmpt to execute a non-executable application
    #>
    [CmdletBinding()]
    param(
        # If you want to show a status even on successful commands, set this
        [string]$Success = "",

        # A string to show when a CommandNotFoundException is thrown.
        # Defaults to "🔍"
        [string]$NotFound = "🔍",

        # A string to show when an ApplicationFailedException is thrown.
        # This is typical for non-executable files on 'nix
        # Defaults to "🚫"
        [string]$NotExecutable = "🚫"
    )
    # If there was an error ...
    if (-not $? -or -not [PoshCode.TerminalBlock]::LastSuccess) {
        if (!$Prefix) { $Prefix = "💣" }
        # We retrieve the InvocationInfo from the most recent error using $global:error[0]
        if ($LastError = $global:error[0]) {
            # If History[-1] matches Error[0].ErrorInvocationInfo then the last error NOT a native command
            if ($LastError.ErrorInvocationInfo -and (Get-History -Count 1).CommandLine -eq $global:error[0].ErrorInvocationInfo.Line) {
                if ($NotFound -and $LastError.Exception -is [System.Management.Automation.CommandNotFoundException]) {
                    $NotFound
                } elseif ($NotExecutable -and $LastError.Exception -is [System.Management.Automation.ApplicationFailedException]) {
                    $NotExecutable
                }
            } else {
                $(if ([PoshCode.TerminalBlock]::LastExitCode) { [PoshCode.TerminalBlock]::LastExitCode } else { $LASTEXITCODE })
            }
        }
    } elseif ($Success) {
        $Success
    }
}
