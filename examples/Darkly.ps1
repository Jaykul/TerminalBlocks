[PoshCode.TerminalBlock[]]$Blocks = @(
    New-TerminalBlock -DFg '#000000' -DBg '#FFFFFF' -Content { $MyInvocation.HistoryId }
    New-TerminalBlock -Spacer
    New-TerminalBlock -DFg '#000000' -DBg '#D6D6D6' -Content { Show-Path -HomeString "&House;" -Length 35 }
    New-TerminalBlock -DFg '#000000' -DBg '#898989' -Alignment 'Right' -Content { Get-Date -f "T" }
    New-TerminalBlock -Spacer -Alignment Right
    New-TerminalBlock -DFg '#000000' -DBg '#656565' -Alignment 'Right' -Content { Get-Elapsed -Trim }
    New-TerminalBlock -Spacer -Alignment Right
    New-TerminalBlock -DFg '#000000' -DBg '#AEAEAE' -Alignment 'Right' -Content { Write-VcsStatus }
    # New-TerminalBlock -Newline
    # New-TerminalBlock -DFg '#000000' -DBg '#656565' -Alignment 'Right' -Content { Show-AzureContext -Force }
    # New-TerminalBlock -DFg '#EBE7EE' -DBg '#434343' -Alignment 'Right' -Content { Show-DockerContext }
    # New-TerminalBlock -DFg '#FFFFFF' -DBg '#242424' -Alignment 'Right' -Content { Show-KubeContext }
    New-TerminalBlock -DFg '#AEAEAE' -DBg '#434343' -Content '&ColorSeparator;'
)

Write-TerminalBlock #Prompt
