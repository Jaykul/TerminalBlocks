function Show-CondaContext {
    <#
        .SYNOPSIS
            Shows the current anaconda context (if any)
        .DESCRIPTION
            Shows the current conda context (the value of the environment variable: CONDA_PROMPT_MODIFIER)
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "&nf-dev-python; "
        [string]$Prefix = "&nf-dev-python; "
    )
    $Env:CONDA_PROMPT_MODIFIER
}
