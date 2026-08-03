function Show-DockerContext {
    <#
        .SYNOPSIS
            Show the docker context
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "${emoji:whale}"
        [string]$Prefix = "${emoji:whale} "
    )
    if (Get-Command docker) {
        if (($Context = docker context show)) {
            $Context
        }
    }
}
