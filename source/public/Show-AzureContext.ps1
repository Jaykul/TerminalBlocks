function Show-AzureContext {
    [Alias("AzureContextBlock","New-AzureContextBlock")]
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "${fg:32aee7}${nf:md-microsoft_azure} ${fg:clear}"
        $Prefix = "$fg:32aee7${nf:md-microsoft_azure} ${fg:clear}",

        # A hashtable of Subscription Ids to the desired text to show.
        [hashtable]$SubscriptionNames,

        # Force imports the module if it's not imported
        # By default, this block only renders when Az.Accounts is imported.
        [switch]$Force
    )
    if ($Force -or (Get-Module Az.Accounts)) {
        if (($Context = Get-AzContext)) {
            if ($SubscriptionNames -and $SubscriptionNames.ContainsKey($Context.Subscription.Id)) {
                $SubscriptionNames[$Context.Subscription.Id]
            } else {
                $Context.Name
            }
        }
    }
}
