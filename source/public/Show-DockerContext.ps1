function Show-DockerContext {
    <#
        .SYNOPSIS
            Show the docker context
    #>
    [CmdletBinding()]
    param()

    if (!$Prefix) { $Prefix = "&whale; " }
    if (Get-Command docker) {
        if (($Context = docker context show)) {
            $Context
        }
    }
}
