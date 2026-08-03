function Show-Palette {
    <#
        .SYNOPSIS
            Shows the 16 colors of the terminal color palette
        .DESCRIPTION
            Shows the 16 colors of the terminal color palette, in two sections, separated by the separator.
            The first section displays the standard colors, while the second section displays the bright colors.
        .EXAMPLE
            Show-Palette
            [40m   [48;2;139;0;0m   [48;2;0;100;0m   [48;2;205;205;0m   [48;2;0;0;139m   [48;2;139;0;139m   [48;2;0;139;139m   [48;2;190;190;190m   [49m
            [48;2;169;169;169m   [41m   [42m   [43m   [44m   [45m   [46m   [47m   [49m
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param()
    "${bg:Black}   ${bg:Red}   ${bg:Green}   ${bg:Yellow}   ${bg:Blue}   ${bg:Magenta}   ${bg:Cyan}   ${bg:White}   ${bg:Default}"
    "${bg:BrightBlack}   ${bg:BrightRed}   ${bg:BrightGreen}   ${bg:BrightYellow}   ${bg:BrightBlue}   ${bg:BrightMagenta}   ${bg:BrightCyan}   ${bg:BrightWhite}   ${bg:Default}"

}

