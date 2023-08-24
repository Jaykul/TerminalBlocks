function Show-UserName {
    <#
        .SYNOPSIS
            Gets the Username of the current machine
        .DESCRIPTION
            Calls [Environment]::UserName
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param()
    [Environment]::UserName
}
