function Show-Palette {
    <#
        .SYNOPSIS
            Shows the 16 colors of the terminal color palette
        .DESCRIPTION
            Shows the 16 colors of the terminal color palette, in two sections, separated by the separator.
            The first section displays the standard colors, while the second section displays the bright colors.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param()
    "${bg:Black}   ${bg:DarkRed}   ${bg:DarkGreen}   ${bg:DarkYellow}   ${bg:DarkBlue}   ${bg:DarkMagenta}   ${bg:DarkCyan}   ${bg:Gray}   ${bg:clear}"
    "${bg:DarkGray}   ${bg:Red}   ${bg:Green}   ${bg:Yellow}   ${bg:Blue}   ${bg:Magenta}   ${bg:Cyan}   ${bg:White}   ${bg:clear}"
}
