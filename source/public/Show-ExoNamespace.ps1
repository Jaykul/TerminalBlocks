function Show-ExoNamespace {
    <#
        .SYNOPSIS
            Shows the current Exchange Online Account Namespace
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
        if (Get-Command Get-FederatedOrganizationIdentifier -ErrorAction Ignore) {
            (Get-FederatedOrganizationIdentifier).AccountNamespace
        }
    }
}


(Get-AcceptedDomain).Where{$_.Default}.Name

