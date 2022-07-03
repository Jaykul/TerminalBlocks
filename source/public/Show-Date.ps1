function Show-Date {
    <#
        .SYNOPSIS
            Get the time span elapsed during the execution of command (by default the previous command)
        .DESCRIPTION
            Calls Get-History to return a single command and returns the difference between the Start and End execution time
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param(
        # A DateTime format string such as "h\:mm\:ss". Defaults to "T"
        [Parameter(ParameterSetName = 'SimpleFormat')]
        [string]$Format = "T"
    )
    end {
        Get-Date -Format $Format
    }
}
