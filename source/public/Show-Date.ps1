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
        # A string to show before the output. Defaults to "📆"
        [string]$Prefix = "📆",

        # A DateTime format string such as "h\:mm\:ss". Defaults to "T"
        [Parameter(ParameterSetName = 'SimpleFormat')]
        [string]$Format = "T"
    )
    $Prefix + (Get-Date -Format $Format)
}
