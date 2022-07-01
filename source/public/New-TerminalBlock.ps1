function New-TerminalBlock {
    <#
        .Synopsis
            Create PoshCode.TerminalBlock with variable background colors
        .Description
            Allows changing the foreground and background colors based on elevation or success.

            Tests elevation fist, and then whether the last command was successful, so if you pass separate colors for each, the Elevated*Color will be used when PowerShell is running as administrator and there is no error. The Error*Color will be used whenever there's an error, whether it's elevated or not.
        .Example
            New-TerminalBlock { Show-ElapsedTime } -ForegroundColor White -BackgroundColor DarkBlue -ErrorBackground DarkRed -ElevatedForegroundColor Yellow

            This example shows the time elapsed executing the last command in White on a DarkBlue background, but switches the text to yellow if elevated, and the background to red on error.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'New is not state changing!')]
    [OutputType([PoshCode.TerminalBlock])]
    [CmdletBinding(DefaultParameterSetName = "Content")]
    [Alias("TerminalBlock", "Block")]
    param(
        # The text, object, or scriptblock to show as output
        [AllowNull()][EmptyStringAsNull()]
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "Content")] # , Mandatory=$true
        [Alias("InputObject")]
        $Content,

        # A special block that outputs just a newline (with no caps, ever)
        [Parameter(Mandatory, ParameterSetName = "Newline")]
        [switch]$Newline,

        # A special block that outputs an inverted Cap (to create gaps in PowerLine)
        [Parameter(Mandatory, ParameterSetName = "Spacer")]
        [switch]$Spacer,

        # A special block that stores the position it would have output at
        [Parameter(Mandatory, ParameterSetName = "StorePosition")]
        [switch]$StorePosition,

        # A special block that recalls to the position of a previous StorePosition block
        [Parameter(Mandatory, ParameterSetName = "RecallPosition")]
        [switch]$RecallPosition,

        [PoshCode.TerminalPosition]$Position,

        [PoshCode.BlockAlignment]$Alignment,

        [Alias("Prepend")]
        [String]$Prefix,

        [Alias("Suffix", "Append")]
        [String]$Postfix,

        # The separator character(s) are used between blocks of output by this scriptblock
        # Pass two characters: the first for normal (Left aligned) blocks, the second for right-aligned blocks
        [ArgumentCompleter({
                [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new(
                    [System.Management.Automation.CompletionResult[]]@(
                        # The Consolas-friendly block characters ▌and▐ and ╲ followed by all the extended Terminal cahracters
                        @([string[]][char[]]@(@(0xe0b0..0xe0d4) + @(0x2588..0x259b) + @(0x256d..0x2572))).ForEach({
                                [System.Management.Automation.CompletionResult]::new("'$_'", $_, "ParameterValue", $_) })
                    ))
            })]
        [String]$Separator,

        # The cap character(s) are used on the ends of blocks of output
        # Pass two characters: the first for normal (Left aligned) blocks, the second for right-aligned blocks
        [ArgumentCompleter({
                [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new(
                    [System.Management.Automation.CompletionResult[]]@(
                        # The Consolas-friendly block characters ▌and▐ and ╲ followed by all the extended Terminal cahracters
                        @([string[]][char[]]@(@(0xe0b0..0xe0d4) + @(0x2588..0x259b) + @(0x256d..0x2572))).ForEach({
                                [System.Management.Automation.CompletionResult]::new("'$_'", $_, "ParameterValue", $_) })
                    ))
            })]
        [PoshCode.BlockCaps]$Caps,

        # The foreground color to use when the last command succeeded
        [Alias("ForegroundColor", "Fg", "DFg")]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$DefaultForegroundColor,

        # The background color to use when the last command succeeded
        [Alias("BackgroundColor", "Bg", "DBg")]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$DefaultBackgroundColor,

        # The foreground color to use when the process is elevated (running as administrator)
        [Alias("AdminFg","AFg")]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$AdminForegroundColor,

        # The background color to use when the process is elevated (running as administrator)
        [Alias("AdminBg","ABg")]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$AdminBackgroundColor,

        # The foreground color to use when the last command failed
        [Alias("ErrorFg", "EFg")]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$ErrorForegroundColor,

        # The background color to use when the last command failed
        [Alias("ErrorBg", "EBg")]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$ErrorBackgroundColor
    )
    process {
        switch($PSCmdlet.ParameterSetName) {
            Newline {
                $PSBoundParameters["Content"] = [PoshCode.SpecialBlock]::NewLine
                $null = $PSBoundParameters.Remove("Newline")
            }
            Spacer {
                $PSBoundParameters["Content"] = [PoshCode.SpecialBlock]::Spacer
                $null = $PSBoundParameters.Remove("Spacer")
            }
            StorePosition {
                $PSBoundParameters["Content"] = [PoshCode.SpecialBlock]::StorePosition
                $null = $PSBoundParameters.Remove("StorePosition")
            }
            RecallPosition {
                $PSBoundParameters["Content"] = [PoshCode.SpecialBlock]::RecallPosition
                $null = $PSBoundParameters.Remove("RecallPosition")
            }
        }

        # Strip common parameters if they're on here (so we can use -Verbose)
        foreach($name in [System.Management.Automation.PSCmdlet]::CommonParameters) {
            $null = $PSBoundParameters.Remove($name)
        }

        [PoshCode.TerminalBlock]$PSBoundParameters
    }
}
