function Show-PoshGitStatus {
    <#
        .SYNOPSIS
            Shows the git status of the current working directory.
        .DESCRIPTION
            Calls PoshGit's Get-GitStatus & Write-GitStatus to display the git status

            Configure via $global:GitPromptSettings
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param()
    dynamicparam {
        $Parameters = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
        if (Get-Module posh-git) {
            if ($global:GitPromptSettings) {
                foreach($Setting in $GitPromptSettings | Get-Member -Type Property) {
                    if ($Setting.Name -notin $MyInvocation.MyCommand.Parameters.Keys) {
                        # $Type = $GitPromptSettings.($Setting.Name).GetType()
                        $Type = $GitPromptSettings.GetType().GetProperty($Setting.Name).PropertyType
                        if ($Type -eq [bool]) {
                            $Type = [switch]
                        }

                        $param = [Management.Automation.RuntimeDefinedParameter]@{
                            Name          = $Setting.Name
                            ParameterType = $Type
                        }
                        $param.Attributes.Add(
                            [Parameter]@{
                                ParameterSetName = "__AllParameterSets"
                                Mandatory        = $false
                            }
                        )
                        #  $param.Attributes.Add([ValidateSet]::new([String[]]@(...)))
                        $Parameters.Add($param.Name, $param)
                    }
                }
                $Parameters
            }
        }
    }
    # Use the BEGIN block for one-time setup that doesn't need to be re-calculated in the prompt every time
    begin {
        foreach($param in $PSBoundParameters.Keys) {
            if ($Parameters.ContainsKey($param)) {
                $global:GitPromptSettings.$param = $PSBoundParameters[$param]
            }
        }
    }
    # The end block will be turned into a closure and a TerminalBlock will be created
    end {
        if (Get-Module posh-git) {
            posh-git\Write-GitStatus (posh-git\Get-GitStatus)
        }
    }
}
