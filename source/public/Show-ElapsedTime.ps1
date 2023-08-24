function Show-ElapsedTime {
    <#
        .SYNOPSIS
            Get the time span elapsed during the execution of command (by default the previous command)
        .DESCRIPTION
            Calls Get-History to return a single command and returns the difference between the Start and End execution time
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param(
        # A string to show before the output.
        [string]$Prefix = "&stopwatch;",

        # A Timespan format pattern such as "{0:ss\.fff}" defaults to "{0:d\d\ h\:mm\:ss\.fff}"
        # See https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
        # See also: https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
        [Parameter(ParameterSetName = 'SimpleFormat')]
        [string]$Format = "{0:d\d\ h\:mm\:ss\.fff}",

        # Automatically use different formats depending on the duration
        [Parameter(Mandatory, ParameterSetName = 'AutoFormat')]
        [switch]$Autoformat
    )
    $LastCommand = Get-History -Count 1
    if(!$LastCommand) { return "" }

    $Duration = $LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime
    $Result = if ($Autoformat) {
        if ($Duration.Days -ne 0) {
            "{0:d\d\ h\:mm}" -f $Duration
        } elseif ($Duration.Hours -ne 0) {
            "{0:h\:mm\:ss}" -f $Duration
        } elseif ($Duration.Minutes -ne 0) {
            "{0:m\:ss\.fff}" -f $Duration
        } elseif ($Duration.Seconds -ne 0) {
            "{0:s\.fff}s" -f $Duration
        } elseif ($Duration.Milliseconds -gt 10) {
            ("{0:fff}ms" -f $Duration).Trim("0")
        } else {
            # 956 is μ (for microsecond), but Windows PowerShell has a hard time with UTF-8 unless there's a BOM, so this is for safety
            ("{0:ffffff}$([char]956)s" -f $Duration).Trim("0")
        }
    } else {
        $Format -f $Duration
    }
    $Result
}
