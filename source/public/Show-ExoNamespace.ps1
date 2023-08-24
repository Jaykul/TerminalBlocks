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
    if (Get-Command Get-FederatedOrganizationIdentifier -ErrorAction Ignore) {
        (Get-FederatedOrganizationIdentifier).AccountNamespace
    } <# elseif (Get-Command Get-AcceptedDomain -ErrorAction Ignore) {
        (Get-AcceptedDomain).Where{ $_.Default }.Name
    } #>
}
