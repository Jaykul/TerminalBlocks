$script:TerminalBlockParams = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
$NewTerminalBlock = Get-Command New-TerminalBlock

foreach ( $name in "DefaultBackgroundColor", "DefaultForegroundColor", "AdminBackgroundColor", "AdminForegroundColor", "ErrorBackgroundColor", "ErrorForegroundColor", "Alignment", "Cap", "Separator", "Position") {
    $parameter = $NewTerminalBlock.Parameters[$name]

    $param = [System.Management.Automation.RuntimeDefinedParameter]::new($parameter.Name, $parameter.ParameterType, $parameter.Attributes)
    $TerminalBlockParams.Add($name, $param)
}
