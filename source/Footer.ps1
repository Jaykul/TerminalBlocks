& {
    if (Get-Command Add-MetadataConverter -ErrorAction Ignore) {
        $AsConverters = @{}
        foreach($command in Get-Command Show-*, New-TerminalBlock -Module TerminalBlocks) {
            $AsConverters[$command.Name] = $command.ScriptBlock
        }
        Add-MetadataConverter $AsConverters
    }
}
