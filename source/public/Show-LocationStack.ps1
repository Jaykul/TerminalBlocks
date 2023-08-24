function Show-LocationStack {
    <#
        .SYNOPSIS
            Show information about the location stack
            TODO: allow passing a stack name
            TODO: allow showing where popd would go to
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
        if ($depth = (Get-Location -Stack).count) {
            if ($RepeatCharacter) {
                $RepeatCharacter * $depth
            } elseif ($LevelStrings -and $LevelStrings.Length -ge $depth) {
                $LevelStrings[$depth - 1]
            } else {
                $depth
            }
        }
    }
}
