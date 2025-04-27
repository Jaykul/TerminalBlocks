function Show-CPUName {
    <#
        .SYNOPSIS
            Shows the name of the primary central processing unit
        .NOTES
            This function is not implemented for macOS or Linux yet.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param()

    if ($PSVersion.Major -lt 6 -or $IsWindows) {
        (Get-ItemProperty -Path HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0 -Name ProcessorNameString).ProcessorNameString.Trim()
    } elseif ($IsOSX) {
        # TODO
    } elseif ($IsLinux) {
        # TODO
    }
}
