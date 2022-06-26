function Show-DockerContext {
    <#
        .SYNOPSIS
            Show the docker context
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output.
        [string]$Prefix = "&whale; "
    )
    if (Get-Command docker) {
        if (($Context = docker context show)) {
            $Prefix + $Context
        }
    }
}
