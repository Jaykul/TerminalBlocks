function Show-ExoNamespace {
    <#
        .SYNOPSIS
            Shows the current Exchange Online Account Namespace
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "&nf-md-microsoft_office; "
        [string]$Prefix = "&nf-md-microsoft_office; "
    )
    if (Get-Command Get-FederatedOrganizationIdentifier -ErrorAction Ignore) {
        (Get-FederatedOrganizationIdentifier).AccountNamespace
    } <# elseif (Get-Command Get-AcceptedDomain -ErrorAction Ignore) {
        (Get-AcceptedDomain).Where{ $_.Default }.Name
    } #>
}
