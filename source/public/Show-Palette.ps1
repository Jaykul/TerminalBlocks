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
    "`e[40m   `e[41m   `e[42m   `e[43m   `e[44m   `e[45m   `e[46m   `e[47m   `e[0m"
    "`e[100m   `e[101m   `e[102m   `e[103m   `e[104m   `e[105m   `e[106m   `e[107m   `e[0m"
}
