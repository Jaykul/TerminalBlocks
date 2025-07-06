function Show-LastExitCode {
    <#
        .SYNOPSIS
            Show the LASTEXITCODE
        .DESCRIPTION
            Shows the exit code for native apps if the last command failed and left a LASTEXITCODE

            Can also show something for CommandNotFound or attmpt to execute a non-executable application
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "&bomb;"
        [string]$Prefix = "&bomb;",

        # If you want to show a status even on successful commands, set this
        [string]$Success = "",

        # A string to show when a CommandNotFoundException is thrown.
        # Defaults to "🔍"
        [string]$NotFound = "&magnifying_glass_tilted_left;",

        # A string to show when an ApplicationFailedException is thrown.
        # This is typical for non-executable files on 'nix
        # Defaults to "🚫"
        [string]$NotExecutable = "&prohibited;"
    )
    # If there was an error ...
    if (-not $? -or -not [PoshCode.TerminalBlocks.Block]::LastSuccess) {
        # We retrieve the InvocationInfo from the most recent error using $global:error[0]
        # If it was a native command, and there are no other errors, this would be empty
        $LastError = $global:error[0]
        # If History[-1] matches Error[0].ErrorInvocationInfo then the last error was NOT a native command
        if ($LastError.InvocationInfo -and (Get-History -Count 1).CommandLine -eq $LastError.InvocationInfo.Line) {
            if ($NotFound -and $LastError.Exception -is [System.Management.Automation.CommandNotFoundException]) {
                $NotFound
            } elseif ($NotExecutable -and $LastError.Exception -is [System.Management.Automation.ApplicationFailedException]) {
                $NotExecutable
            }
        } else {
            if ([PoshCode.TerminalBlocks.Block]::LastExitCode -gt 0) {
                [PoshCode.TerminalBlocks.Block]::LastExitCode.ToString()
            } elseif ($global:LASTEXITCODE -gt 0) {
                $global:LASTEXITCODE
            }
        }
    } elseif ($Success) {
        $Success
    }
}
