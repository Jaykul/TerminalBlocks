function ImportBlock {
    <#
        .SYNOPSIS
            Parses the given code and returns an object with the AST, Tokens and ParseErrors
    #>
    param(
        # The script content, or script or module file path to parse
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Code
    )
    process {
        $Command, $null = $Code.Split(" ", 2, "RemoveEmpty")

        Write-Verbose "Verifying Block command: $Command"

        # Autoload the block so we don't re-parse it every time
        if (($Path = Get-Item "$PSScriptRoot\blocks\${Command}.ps1" -ErrorAction SilentlyContinue)) {
            Write-Verbose "Set $($Path.BaseName) = $Path"
            Set-Content "function:global:$($Path.BaseName)" (Get-Command $Path).ScriptBlock
            return $true
        }

        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            Write-Verbose "Found command $Command"
            return $true
        }
        Write-Verbose "Command not found $Command"
        return $false
    }
}
