function Show-ErrorCount {
    <#
        .SYNOPSIS
            Get a count of new errors from previous command
        .DESCRIPTION
            Detects new errors generated by previous command based on tracking last seen count of errors.
    #>
    [CmdletBinding()]
    param(
        # If set, always show the output
        [switch]$ShowZero
    )

    $Count = $global:Error.Count - $script:LastErrorCount
    $script:LastErrorCount = $global:Error.Count
    if ($ShowZero -or $Count -gt 0) {
        $Count
    }
}
