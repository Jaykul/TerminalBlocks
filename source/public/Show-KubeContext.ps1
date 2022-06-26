function Show-KubeContext {
    <#
        .SYNOPSIS
            Shows the current kubectl context
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output.
        [string]$Prefix = "${fg:316ce6}⎈$fg:clear "
    )
    if (Get-Command kubectl) {
        if (($Context = kubectl config current-context)) {
            $Prefix + $Context
        }
    }
}
