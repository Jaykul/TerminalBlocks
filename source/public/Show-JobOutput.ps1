function Show-JobOutput {
    <#
        .SYNOPSIS
            Shows the most recent output of a specific job.
        .DESCRIPTION
            Calls Get-Job and returns the last output
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The name of the job to show the output of
        [string]$Name
    )
    $Job = Get-Job -Name $Name -ErrorAction SilentlyContinue
    if ($Job.Output.Count) {
        $Job.Output[-1]
    }
}


