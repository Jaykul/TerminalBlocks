function Write-TerminalBlock {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [PoshCode.TerminalBlock[]]$Blocks = $global:Blocks,

        [switch]$NoCache
    )
    end {
        # Stuff these into static properties in case I want to use them from C#
        [PoshCode.TerminalBlock]::LastSuccess = $global:?
        [PoshCode.TerminalBlock]::LastExitCode = $global:LASTEXITCODE

        $CacheKey = if ($NoCache) { [Guid]::NewGuid() } else { $MyInvocation.HistoryId }

        # invoke them all, to find out if they have content
        $PromptErrors = [ordered]@{}
        for ($b = 0; $b -lt $Blocks.Count; $b++) {
            try {
                $null = $Blocks[$b].Invoke($CacheKey)
            } catch {
                $PromptErrors.Add("$b { $($Blocks[$b].Content) }", $_)
            }
        }

        # now output them all
        $result = [System.Text.StringBuilder]::new()
        for ($b = 0; $b -lt $Blocks.Count; $b++) {
            $Neighbor = @{}
            $Block = $Blocks[$b]

            $n = $b
            # Your neighbor is the next non-empty block with the same alignment as you
            while (++$n -lt $Blocks.Count -and $Block.Alignment -eq $Blocks[$n].Alignment) {
                if ($Blocks[$n].Cache) {
                    $Neighbor = $Blocks[$n]
                    break;
                }
            }

            # Don't render spacers, if they don't have a real (non-space) neighbors
            if ($Block.Content -eq [PoshCode.BlockSpace]::Spacer -and (!$Neighbor.Cache -or $Neighbor.Content -eq [PoshCode.BlockSpace]::Spacer)) {
                continue
            }

            $null = $result.Append($Block.ToLine($Neighbor.BackgroundColor, $CacheKey))
        }
        $result.ToString()
    }
}
