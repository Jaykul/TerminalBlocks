function Show-PoshGitStatus {
    <#
        .SYNOPSIS
            Shows the git status of the current working directory.
        .DESCRIPTION
            Calls PoshGit's Get-GitStatus & Write-GitStatus to display the git status

            Configure via $global:GitPromptSettings
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param()
    end {
        Write-GitStatus (Get-GitStatus)
    }
}
