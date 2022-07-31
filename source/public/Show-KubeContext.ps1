function Show-KubeContext {
    <#
        .SYNOPSIS
            Shows the current kubectl context
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output.
        [string]$Prefix = "&nf-mdi-ship_wheel; "
    )
    if (Get-Command kubectl) {
        if (($Context = kubectl config current-context)) {
            $Context
        }
    }
}
