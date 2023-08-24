function Show-NestedPromptLevel {
    <#
        .SYNOPSIS
            Show the nested prompt level (if any)
    #>
    [CmdletBinding()]
    param(
        # Count prefix is used as a prefix for the number
        # The default is "⛯ " so "⛯ 3" will be used for $NestedPromptlevel = 3
        [string]$CountPrefix = "&gear; ",

        # If set, Repeat is repeated for each nested level
        # E.g. if you set "*" then "***" will be used for $NestedPromptlevel = 3
        [string]$RepeatCharacter,

        # LevelStrings allows you to specify an array of exact values to use for each $NestedPromptlevel (starts at 1)
        # E.g.: @("&gear;", "&gear;&gear;", "&gear;3", "&gear;4", "&gear;5", "&gear;6", "&gear;7", "&gear;8", "&gear;9")
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
