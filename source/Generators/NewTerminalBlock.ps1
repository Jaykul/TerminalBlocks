    [CmdletBinding()]
    param(
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
        # Pass two characters: the first for the left side, the second for the right side.
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
        [Alias("AdminFg", "AFg")]
        [AllowNull()][EmptyStringAsNull()]
        [PoshCode.Pansies.RgbColor]$AdminForegroundColor,

        # The background color to use when the process is elevated (running as administrator)
        [Alias("AdminBg", "ABg")]
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
    end {
        $PSBoundParameters["Content"] = {
            existingcode
        }.GetNewClosure()

        # Strip common parameters if they're on here (so we can use -Verbose)
        foreach ($name in @($PSBoundParameters.Keys.Where{$_ -notin [PoshCode.TerminalBlock].GetProperties().Name})) {
            $null = $PSBoundParameters.Remove($name)
        }

        $PSBoundParameters["MyInvocation"] = [System.Management.Automation.InvocationInfo].GetProperty("ScriptPosition", [System.Reflection.BindingFlags]"Instance,NonPublic").GetValue($MyInvocation).Text

        [PoshCode.TerminalBlock]$PSBoundParameters
    }
