function Show-KubeContext {
    <#
        .SYNOPSIS
            Shows the current kubectl context
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "&nf-mdi-ship_wheel; "
        [string]$Prefix = "&nf-mdi-ship_wheel; "
    )
    if (Get-Command kubectl -ErrorAction Ignore) {
        if (($Context = kubectl config current-context)) {
            $Context
        }
    }
}
