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
    [CmdletBinding(DefaultParameterSetName = "InputObject")]
    [Alias("TerminalBlock", "Block")]
    param(
        # The text, object, or scriptblock to show as output
        [AllowNull()][EmptyStringAsNull()]
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "InputObject")] # , Mandatory=$true
        [Alias("Content")]
        $InputObject,

        [PoshCode.TerminalPosition]$Position,

        [PoshCode.BlockAlignment]$Alignment,

        # Add a line break to the prompt (the next block will start a new line)
        [Parameter(Mandatory, ParameterSetName = "Newline")]
        [Switch]$Newline,

        # Add a zero-width space to the prompt (creates a gap between blocks)
        [Parameter(Mandatory, ParameterSetName = "Spacer")]
        [Switch]$Spacer,

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
        [PoshCode.BlockCap]$Separator,

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
        [PoshCode.BlockCap]$Cap,

        # The foreground color to use when the last command succeeded
        [Alias("ForegroundColor", "Fg", "DFg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$DefaultForegroundColor,

        # The background color to use when the last command succeeded
        [Alias("BackgroundColor", "Bg", "DBg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$DefaultBackgroundColor,

        # The foreground color to use when the process is elevated (running as administrator)
        [Alias("AdminFg","AFg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$AdminForegroundColor,

        # The background color to use when the process is elevated (running as administrator)
        [Alias("AdminBg","ABg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$AdminBackgroundColor,

        # The foreground color to use when the last command failed
        [Alias("ErrorFg", "EFg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$ErrorForegroundColor,

        # The background color to use when the last command failed
        [Alias("ErrorBg", "EBg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$ErrorBackgroundColor
    )
    process {
        if ($Newline) {
            $InputObject = [PoshCode.BlockSpace]::NewLine
            $null = $PSBoundParameters.Remove("Newline")
        } elseif ($Spacer) {
            $InputObject = [PoshCode.BlockSpace]::Spacer
            $null = $PSBoundParameters.Remove("Spacer")
        }

        # Handle named terminal blocks
        $PSBoundParameters["InputObject"] = switch ($InputObject) {
            "`n"    { [PoshCode.BlockSpace]::NewLine }
            " "     { [PoshCode.BlockSpace]::Spacer }
            default { $InputObject }
        }

        # Strip common parameters if they're on here (so we can use -Verbose)
        foreach($name in [System.Management.Automation.PSCmdlet]::CommonParameters) {
            $null = $PSBoundParameters.Remove($name)
        }

        [PoshCode.TerminalBlock]$PSBoundParameters
    }
}
