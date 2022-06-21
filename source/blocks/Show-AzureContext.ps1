[CmdletBinding()]
param(
    [string]$Icon = "$fg:32aee7&nf-mdi-azure;$fg:clear ",

    # Force imports the module if it's not imported
    # By default, this block only renders when Az.Cccounts is imported.
    [switch]$Force
)
if ($Force -or (Get-Module Az.Accounts)) {
    if (($Context = Get-AzContext)) {
        $Icon + $Context.Name
    }
}
