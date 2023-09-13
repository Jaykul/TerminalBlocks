function Show-Date {
    <#
        .SYNOPSIS
            Get the current date and/or time (by default, just the time).
        .DESCRIPTION
            Just calls Get-Date and passes the -Format and -AsUTC parameters.
        .EXAMPLE
            Show-Date -Format "h\:mm"

            Shows the time in 12 hour format without seconds.
        .EXAMPLE
            Show-Date -Format "H\:mm" -AsUTC

            Shows the UTC time in 24 hour format without seconds.
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
    # PS5 doesn't have -AsUTC
    if ($AsUTC) {
        Get-Date -Format $Format (Get-Date).ToUniversalTime()
    } else {
        Get-Date -Format $Format
    }
}
