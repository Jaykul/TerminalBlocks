[CmdletBinding()]
param(
    [string]$Icon = "${fg:316ce6}⎈$fg:clear "
)
if (Get-Command kubectl) {
    if (($Context = kubectl config current-context)) {
        $Icon + $Context
    }
}
