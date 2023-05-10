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

        # A special block that creates a column break in PowerLine
        [Parameter(Mandatory, ParameterSetName = "ColumnBreak")]
        [switch]$ColumnBreak,

        # A special block that stores the position it would have output at
        [Parameter(Mandatory, ParameterSetName = "StorePosition")]
        [switch]$StorePosition,

        # A special block that recalls to the position of a previous StorePosition block
        [Parameter(Mandatory, ParameterSetName = "RecallPosition")]
        [switch]$RecallPosition
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
            ColumnBreak {
                $PSBoundParameters["Content"] = [PoshCode.SpecialBlock]::ColumnBreak
                $null = $PSBoundParameters.Remove("ColumnBreak")
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
