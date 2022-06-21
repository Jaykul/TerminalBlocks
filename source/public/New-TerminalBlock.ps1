function New-TerminalBlock {
    <#
        .Synopsis
            Create PoshCode.TerminalBlock with variable background colors
        .Description
            Allows changing the foreground and background colors based on elevation or success.

            Tests elevation fist, and then whether the last command was successful, so if you pass separate colors for each, the Elevated*Color will be used when PowerShell is running as administrator and there is no error. The Error*Color will be used whenever there's an error, whether it's elevated or not.
        .Example
            New-TerminalBlock { Get-Elapsed } -ForegroundColor White -BackgroundColor DarkBlue -ErrorBackground DarkRed -ElevatedForegroundColor Yellow

            This example shows the time elapsed executing the last command in White on a DarkBlue background, but switches the text to yellow if elevated, and the background to red on error.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'New is not state changing!')]
    [OutputType([PoshCode.TerminalBlock])]
    [CmdletBinding(DefaultParameterSetName = "InputObject")]
    [Alias("TerminalBlock", "Block")]
    param(
        # The text, object, or scriptblock to show as output
        [Alias("Content", "Text", "Object")]
        [AllowNull()][EmptyStringAsNull()]
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = "InputObject")] # , Mandatory=$true
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
        [char[]]$Separator,

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
        [char[]]$Cap,

        # The foreground color to use when the last command succeeded
        [Alias("Foreground", "Fg", "DFg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$DefaultForegroundColor,

        # The background color to use when the last command succeeded
        [Alias("Background", "Bg", "DBg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$DefaultBackgroundColor,

        # The foreground color to use when the process is elevated (running as administrator)
        [Alias("AFg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$ElevatedForegroundColor,

        # The background color to use when the process is elevated (running as administrator)
        [Alias("ABg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$ElevatedBackgroundColor,

        # The foreground color to use when the last command failed
        [Alias("EFg")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$ErrorForegroundColor,

        # The background color to use when the last command failed
        [Alias("EBg")]
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
        # Work around possible weird parameter bindings
        }

        # Handle named terminal blocks
        $PSBoundParameters["InputObject"] = switch ($InputObject) {
            { $InputObject.InputObject } { $InputObject.InputObject }
            { $InputObject.Object }      { $InputObject.Object }
            { $InputObject.Text }        { $InputObject = $InputObject.Text }

            "`n"    { [PoshCode.BlockSpace]::NewLine }
            " "     { [PoshCode.BlockSpace]::Spacer }

            default {
                if ($InputObject -is [string] -or $InputObject -is [scriptblock]) {
                    if (($InputObject|ImportBlock) -and $InputObject -is [string]) {
                        Write-Verbose "Creating Scriptblock for { $InputObject }"
                        [ScriptBlock]::create($InputObject)
                        continue
                    }
                }
                $InputObject
            }
        }
        # Strip common parameters if they're on here (so we can use -Verbose)
        $null = [System.Management.Automation.PSCmdlet]::CommonParameters.ForEach({$PSBoundParameters.Remove($_)})

        [PoshCode.TerminalBlock]$PSBoundParameters
    }
}
