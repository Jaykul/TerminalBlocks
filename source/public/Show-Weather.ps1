function Show-Weather {
    <#
        .SYNOPSIS
            Shows the current weather
        .DESCRIPTION
            Calls wttr.in and returns the current weather
        .LINK
            https://github.com/chubin/wttr.in?tab=readme-ov-file#one-line-output
            https://wttr.in/:help
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The wttr format. Can be a single number from 1 to 4, or a custom format string.
        # Defaults to "%c%t" which shows an icon for the conditions, and the temperature.
        # If you can't handle emoji, you might like "%C%t" instead, which shows the conditions in text form
        # If you travel a lot, you might want to prefix with "%l: " to show the detected location.
        # See https://github.com/chubin/wttr.in?tab=readme-ov-file#one-line-output for more options
        [string]$Format = "%c%t",

        # The location to get the weather for. By default relies on wttr.in to determine the location based on your IP address.
        # You can specify a location like "Rochester" or "Rochester, NY" to get the weather for that location.
        # Or you can use a lowercase airport code, area code, GPS coordinates, etc.
        # https://wttr.in/:help for more information.
        [string]$Location,

        # Whether to use "m"etric units (Celsius, km/h, etc.) or "u"SCS units (Fahrenheit, mph, etc.)
        # Defaults to u or m based on whether the current culture is en-US or not.
        [ValidateSet("m", "u")]
        [string]$Units = ($PSUICulture -eq "en-US" ? "u" : "m")
    )
    (Invoke-RestMethod -TimeoutSec 5 "wttr.in/${Location}?${Units}&format=$Format") -replace "[ +]+", " "
}
