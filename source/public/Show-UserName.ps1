function Show-UserName {
    <#
        .SYNOPSIS
            Gets the Username of the current user, and optionally the Computer Name
        .DESCRIPTION
            Calls [Environment]::UserName
        .EXAMPLE
            Show-UserName -ShowComputerName -Separator "@"

            Returns "User@Computer"
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param(
        # Whether to show the Computer Name after the Username
        [switch]$ShowComputerName
    )
    [Environment]::UserName

    if ($ShowComputerName) {
        [Environment]::MachineName
    }
}
