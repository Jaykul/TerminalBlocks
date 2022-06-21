function Write-TerminalBlock {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [PoshCode.TerminalBlock[]]$Blocks = $global:Blocks,

        [switch]$NoCache
    )
    end {
        [PoshCode.TerminalBlock]::LastSuccess = $?
        $CacheKey = if ($NoCache) { [Guid]::NewGuid() } else { $MyInvocation.HistoryId }

        $PromptErrors = [ordered]@{}
        for ($b = 0; $b -lt $Blocks.Count; $b++) {
            try {
                $null = $Blocks[$b].Invoke($CacheKey)
            } catch {
                $PromptErrors.Add("$b { $($Blocks[$b].Content) }", $_)
            }
        }
        -join @(
            for ($b = 0; $b -lt $Blocks.Count; $b++) {
                $Neighbor = @{}
                $Block = $Blocks[$b]

                $n = $b
                # If this is not a spacer, it should use the color of the next non-empty block
                while(++$n -lt $Blocks.Count) {
                    if ($Block.Alignment -ne $Blocks[$n].Alignment) {
                        Write-Verbose "For $b ($($Block.Content)), there's no neighbor"
                        break;
                    }
                    if ($Blocks[$n].Cache) {
                        Write-Verbose "For $b, the neighbor is $n"
                        $Neighbor = $Blocks[$n]
                        break;
                    }
                }

                # If this is a spacer, it should not render at all if the next non-empty block is a spacer or has a different alignment
                if ($Block.Content -eq [PoshCode.BlockSpace]::Spacer -and (
                        -not $Neighbor.Cache -or
                        $Neighbor.Content -eq [PoshCode.BlockSpace]::Spacer -or
                        $Neighbor.Alignment -ne $Block.Alignment)) {
                    Write-Verbose "Don't render $b"
                    continue
                }

                if ($text = $Block.ToLine($Neighbor.BackgroundColor, $CacheKey)) {
                    $text
                }
            }
        )
    }
}
