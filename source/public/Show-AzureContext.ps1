function Show-AzureContext {
    [Alias("AzureContextBlock","New-AzureContextBlock")]
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "$fg:32aee7&nf-mdi-azure;$fg:clear"
        $Prefix = "$fg:32aee7&nf-mdi-azure;$fg:clear",

        # Force imports the module if it's not imported
        # By default, this block only renders when Az.Accounts is imported.
        [switch]$Force
    )
    begin {
        # Force a default prefix
        $PSBoundParameters["Prefix"] = $Prefix
    }
    end {
        if ($Force -or (Get-Module Az.Accounts)) {
            if (($Context = Get-AzContext)) {
                $Context.Name
            }
        }
    }
}
