function Show-KubeContext {
    <#
        .SYNOPSIS
            Shows the current kubectl context
    #>
    [CmdletBinding()]
    param()
    if (!$Prefix) { $Prefix = "⎈ " }
    if (Get-Command kubectl) {
        if (($Context = kubectl config current-context)) {
            $Context
        }
    }
}
