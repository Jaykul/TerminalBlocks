function Show-Memory {
    <#
        .SYNOPSIS
            Shows the total memory (and optionally, free memory)
        .NOTES
            This function is not implemented for macOS or Linux yet.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # Whether to show the amount of used memory before the total memory
        [switch]$ShowUsed,
        # The number of decimal places to round the output to
        [int]$Round = 2
    )

    $Memory = [GC]::GetGCMemoryInfo()
    $Label, $Units = if ($Memory.TotalAvailableMemoryBytes -gt 1TB) {
        "TB", 1TB
    } elseif ($Memory.TotalAvailableMemoryBytes -gt 1GB) {
        "GB", 1GB
    } else {
        "MB", 1MB
    }

    if ($ShowUsed) {
        "{0:N$Round}$Label" -f ($Memory.MemoryLoadBytes / $Units)
    }
    "{0:N$Round}$Label" -f ($Memory.TotalAvailableMemoryBytes / $Units)
}
