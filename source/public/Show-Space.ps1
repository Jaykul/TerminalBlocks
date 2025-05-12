function Show-Space {
    <#
        .SYNOPSIS
            Shows a space
        .DESCRIPTION
            Shows a space block. Still renders caps, so it can be used with background colors to create gaps in a "PowerLine" style output.
        .EXAMPLE
            Show-Space -Caps '',''

            █
        .EXAMPLE
            Show-Space -Caps '',''
    #>
    [OutputType([PoshCode.TerminalBlocks.SpecialBlock])]
    [CmdletBinding()]
    param(
        # The separator character(s) are used between blocks of output by this scriptblock
        # You can pass two characters: the first for normal (Left aligned) blocks, the second for right-aligned blocks
        [ArgumentCompleter({
                [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new(
                    [System.Management.Automation.CompletionResult[]]@(
                        # The Consolas-friendly block characters ▌and▐ and ╲ followed by all the extended Terminal characters
                        @([string[]][char[]]@(@(0xe0b0..0xe0d4) + @(0x2588..0x259b) + @(0x256d..0x2572))).ForEach({
                                [System.Management.Automation.CompletionResult]::new("'$_'", $_, "ParameterValue", $_) })
                    ))
            })]
        [String]$Separator = ' ',

        # The Content of a Spacer is a Spacer. Don't change it
        $Content = [PoshCode.TerminalBlocks.SpecialBlock]::Spacer
    )
}
