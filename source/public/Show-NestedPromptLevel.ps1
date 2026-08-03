function Show-NestedPromptLevel {
    <#
        .SYNOPSIS
            Show the nested prompt level (if any)
    #>
    [CmdletBinding()]
    param(
        # Count prefix is used as a prefix for the number
        # The default is "⛯ " so "⛯ 3" will be used for $NestedPromptlevel = 3
        [string]$CountPrefix = "${emoji:gear} ",

        # If set, Repeat is repeated for each nested level
        # E.g. if you set "*" then "***" will be used for $NestedPromptlevel = 3
        [string]$RepeatCharacter,

        # LevelStrings allows you to specify an array of exact values to use for each $NestedPromptlevel (starts at 1)
        # E.g.: @("${emoji:gear}", "${emoji:gear}${emoji:gear}", "${emoji:gear}3", "${emoji:gear}4", "${emoji:gear}5", "${emoji:gear}6", "${emoji:gear}7", "${emoji:gear}8", "${emoji:gear}9")
        [string[]]$LevelStrings
    )
    begin {
        if (!$RepeatCharacter -and !$LevelStrings) {
            $PSBoundParameters["Prefix"] = $CountPrefix
        }
    }
    end {
        if ($NestedPromptLevel) {
            if ($RepeatCharacter) {
                $RepeatCharacter * $NestedPromptLevel
            } elseif ($LevelStrings -and $LevelStrings.Length -ge $NestedPromptLevel) {
                $LevelStrings[$NestedPromptLevel-1]
            } else {
                $NestedPromptLevel
            }
        }
    }
}
