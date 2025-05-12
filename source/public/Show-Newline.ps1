function Show-Newline {
    <#
        .SYNOPSIS
            Shows a Newline
        .DESCRIPTION
            Shows a Newline
            This is a SpecialBlock that does not render caps or separators or color, but simply outputs a newline character.
        .EXAMPLE
            Show-Newline
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

        # The Content of a Newline is a Newline. Don't change it.
        $Content = [PoshCode.TerminalBlocks.SpecialBlock]::Newline
    )
}
