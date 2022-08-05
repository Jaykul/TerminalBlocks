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
    begin {
        # Force a default prefix
        $PSBoundParameters["Prefix"] = $Prefix
    }
    end {
        if (Get-Command kubectl) {
            if (($Context = kubectl config current-context)) {
                $Context
            }
        }
    }
}
