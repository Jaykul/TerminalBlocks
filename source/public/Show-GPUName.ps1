function Show-GPUName {
    <#
        .SYNOPSIS
            Shows the name of the priomary graphics processing unit
        .NOTES
            This function is not implemented for macOS or Linux yet.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param()

    if ($PSVersion.Major -lt 6 -or $IsWindows) {
        # Limit it to only those that have a known Refresh Rate?
        (Get-CimInstance -ClassName Win32_VideoController -Property Name -Filter "MinRefreshRate > 0").Name
    } elseif ($IsOSX) {
        # TODO
    } elseif ($IsLinux) {
        # TODO
    }
}
