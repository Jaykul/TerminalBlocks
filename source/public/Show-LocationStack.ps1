function Show-LocationStack {
    <#
        .SYNOPSIS
            Show information about the location stack
            TODO: allow passing a stack name
            TODO: allow showing where popd would go to
    #>
    [CmdletBinding()]
    param(
        # If set, this string is repeated for each nested level
        # The default is "&raquo;" so "»»»" will be used for $NestedPromptlevel = 3
        [string]$RepeatCharacter ="&raquo;",

        # LevelStrings allows you to specify an array of exact values to use for each $NestedPromptlevel (starts at 1)
        # E.g.: @("&raquo;", "&raquo;&raquo;", "&raquo;3", "&raquo;4", "&raquo;5", "&raquo;6", "&raquo;7", "&raquo;8", "&raquo;9")
        [string[]]$LevelStrings,

        [string]$StackName = ""
    )
    end {
        if ($depth = [PoshCode.TerminalBlock]::GlobalSessionState.Path.LocationStack($StackName).count) {
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
