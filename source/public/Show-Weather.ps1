function Show-Weather {
    <#
        .SYNOPSIS
            Shows the current weather
        .DESCRIPTION
            Calls wttr.in and returns the current weather
        .LINK
            https://github.com/chubin/wttr.in?tab=readme-ov-file#one-line-output
            https://wttr.in/:help
        .EXAMPLE
            Show-Weather -Format "%w %c%f" -Location (irm ipinfo.io/json).foreach{$_.city + ", " + $_.region}

            Will show the current weather conditions (using "feels like" temperature) and wind for the location determined by ipinfo.io
        .EXAMPLE
            Show-Weather -Format "%c%t" -Location "London, UK"

            Will show the current weather conditions and wind for London (using the actual temperature)
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The wttr format. Can be a single number from 1 to 4, or a custom format string.
        # Defaults to "%c%t" which shows an icon for the conditions, and the temperature.
        # If you can't handle emoji, you might like "%C%t" instead, which shows the conditions in text form
        # If you change locations a lot, you might want to prefix with "%l: " to show the detected location.
        # See https://github.com/chubin/wttr.in?tab=readme-ov-file#one-line-output for more options
        [string]$Format = "%c%t",

        # The location to get the weather for.
        #
        # Because of some problems with wttr.in location detection (see https://github.com/chubin/wttr.in/issues/1073), if you don't specify a location, we use ipinfo.io to get a city, region, and country, but we only fetch this once per session -- so if you need to refresh the location every time, specify it explicitly as in Example 1.
        #
        # You can specify a location like "Atlanta" or "Rochester, NY" or use a lowercase airport code, area code, GPS coordinates, etc.
        # https://wttr.in/:help for more information.
        [string]$Location,

        # Whether to use "m"etric units (Celsius, km/h, etc.) or "u"SCS units (Fahrenheit, mph, etc.)
        # Defaults to u or m based on whether the current culture is en-US or not.
        [ValidateSet("m", "u")]
        [string]$Units = ($PSUICulture -eq "en-US" ? "u" : "m")
    )
    if ($null -eq $Location) {
        # There are some issues with wttr.in's geolocation, so we use ipinfo.io instead, but only fetch it once
        # If you want to fetch this every time, use example 1
        # https://github.com/chubin/wttr.in/issues/1073
        if ($null -eq $Script:GeoLocation) {
            $IpInfoLocation = Invoke-RestMethod ipinfo.io/json
            $Script:GeoLocation = $IpInfoLocation.city, $IpInfoLocation.region, $IpInfoLocation.country
        }
        $Location = $Script:GeoLocation -join ", "
    }

    (Invoke-RestMethod -TimeoutSec 5 "wttr.in/${Location}?${Units}&format=$Format") -replace "[ +]+", " "
}
