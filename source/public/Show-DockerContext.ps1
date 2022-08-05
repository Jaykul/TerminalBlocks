function Show-DockerContext {
    <#
        .SYNOPSIS
            Show the docker context
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "&whale;"
        [string]$Prefix = "&whale; "
    )
    begin {
        # Force a default prefix
        $PSBoundParameters["Prefix"] = $Prefix
    }
    end {
        if (Get-Command docker) {
            if (($Context = docker context show)) {
                $Context
            }
        }
    }
}
