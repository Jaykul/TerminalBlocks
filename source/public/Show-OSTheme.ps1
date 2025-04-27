function Show-OSTheme {
    <#
        .SYNOPSIS
            Shows the Window Theme name (and whether it is Light or Dark)
        .NOTES
            This function is not implemented for macOS or Linux yet.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param()

    if ($PSVersion.Major -lt 6 -or $IsWindows) {
        $themeinfo = Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name SystemUsesLightTheme, AppsUseLightTheme
        $Name = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes' -Name CurrentTheme).CurrentTheme -replace ".*[\\/]([^\\/]+).theme$", '$1' ?? "Default"

        $Mode = if ($themeinfo.SystemUsesLightTheme -ne $themeinfo.AppsUseLightTheme) {
            if ($themeinfo.SystemUsesLightTheme) {
                "Light/Dark"
            } else {
                "Dark/Light"
            }
        } elseif ($themeinfo.SystemUsesLightTheme) {
            "Light"
        } else {
            "Dark"
        }
        "$Name ($Mode)"
    } elseif ($IsOSX) {
        # TODO
    } elseif ($IsLinux) {
        # TODO
    }
}
