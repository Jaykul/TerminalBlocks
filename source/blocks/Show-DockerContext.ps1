[CmdletBinding()]
param(
    [string]$Icon = "&whale; "
)
if (Get-Command docker) {
    if (($Context = docker context show)) {
        $Icon + $Context
    }
}
