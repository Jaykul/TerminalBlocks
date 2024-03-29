function Show-Date {
    <#
        .SYNOPSIS
            Get the current date and/or time (by default, just the time).
        .DESCRIPTION
            Just calls Get-Date and passes the -Format and -AsUTC parameters.
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param(
        # A DateTime format string such as "h\:mm\:ss". Defaults to "T"
        [Parameter(ParameterSetName = 'SimpleFormat')]
        [string]$Format = 'T',

        # Shows the current UTC date (and/or time).
        [switch]$AsUTC
    )
    end {
        Get-Date -Format $Format -AsUTC:$AsUTC
    }
}
