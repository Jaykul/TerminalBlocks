function Show-NestedPromptLevel {
    <#
        .SYNOPSIS
            Show the nested prompt level (if any)
    #>
    [CmdletBinding()]
    param(
        # Count prefix is used as a prefix for the number
        # The default is "» " so "» 3" will be used for $NestedPromptlevel = 3
        [string]$CountPrefix = "&raquo; ",

        # If set, Repeat is repeated for each nested level
        # E.g. if you set "*" then "***" will be used for $NestedPromptlevel = 3
        [string]$RepeatCharacter,

        # LevelStrings allows you to specify an array of exact values to use for each $NestedPromptlevel (starts at 1)
        # E.g.: @("&raquo;", "&raquo;&raquo;", "&raquo;3", "&raquo;4", "&raquo;5", "&raquo;6", "&raquo;7", "&raquo;8", "&raquo;9")
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
