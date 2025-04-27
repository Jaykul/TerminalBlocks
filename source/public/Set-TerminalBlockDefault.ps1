filter Set-TerminalBlockDefault {
    [CmdletBinding()]
    param(
        # Turn on automatic background color for TerminalBlocks
        # If set, any TerminalBlock without a background color will automatically get a background color starting with this color and then incrementing the hue by AutomaticBackgroundHueStep (default 5).
        # As a reminder, a full rotation of hue is 360 degrees, so a hue step of 5 will give you 72 different colors, but these colors will be so similar most people can't tell sequential colors apart.
        # NOTE: By default there is no automatic background color at all.
        # To disable the automatic background color, set this to $null
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [Alias("BackgroundColor")]
        [PoshCode.Pansies.RgbColor]$FirstAutomaticBackgroundColor,
        # The number of degrees to increment the hue by when generating automatic background colors
        # If you set this to 0, it will not increment the hue at all, and the automatic background color will always be the FirstAutomaticBackgroundColor.
        #
        # The default is 5, which gives you 72 different colors in a full rotation of hue (360 degrees).
        # You can set this to a larger value to get colors that are more distinct, but this will also mean fewer colors in the rotation.
        #
        # NOTE: By default there is no automatic background color at all, but if the FirstAutomaticBackgroundColor is set, the default HueStep is 5 degrees.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("HueStep")]
        [int]$AutomaticBackgroundHueStep,

        # The caps to use for TerminalBlocks which have no explicit caps
        # NOTE: The default is "","" if you never set it
        [Parameter(ValueFromPipelineByPropertyName)]
        [PoshCode.BlockCaps]$Caps,

        # The separator to use for TerminalBlocks which have no explicit separator
        # NOTE: The default is a space " " if you never set it
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Separator
    )
    if ($PSBoundParameters.ContainsKey('AutomaticBackgroundHueStep')) {
        [PoshCode.TerminalBlock]::AutomaticBackgroundHueStep = $AutomaticBackgroundHueStep
    }
    if ($PSBoundParameters.ContainsKey('FirstAutomaticBackgroundColor')) {
        [PoshCode.TerminalBlock]::FirstAutomaticBackgroundColor = $FirstAutomaticBackgroundColor
    }
    if ($PSBoundParameters.ContainsKey('Caps')) {
        [PoshCode.TerminalBlock]::DefaultCaps = $Caps
    }
    if ($PSBoundParameters.ContainsKey('Separator')) {
        [PoshCode.TerminalBlock]::DefaultSeparator = $Separator
    }
}
