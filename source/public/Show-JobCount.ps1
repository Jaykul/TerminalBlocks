function Show-JobCount {
    <#
        .SYNOPSIS
            Shows the count of jobs in each state in the current session.
        .DESCRIPTION
            Calls Get-Job to get all jobs in the current session and shows the number of jobs in each state.
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param(
        # A hashtable of job statuses you want to see and labels for them.
        # Defaults to only show three statuses: @{
        #     Running   = "${emoji:play_or_pause_button}"
        #     Completed = "${emoji:check_mark_button}"
        #     Failed    = "${emoji:cl_button}"
        # }
        # But try tricks like putting in colors:
        # @{
        #     Running   = "${fg:green}"
        #     Completed = "${fg:blue}"
        #     Failed    = "${fg:red}"
        # }
        [Parameter(ParameterSetName = 'SimpleFormat')]
        $StateLabels = @{
            Running   = "${emoji:play_or_pause_button}"
            Completed = "${emoji:check_mark_button}"
            Failed    = "${emoji:cl_button}"
        }
    )
    $jobs = Get-Job | Group-Object State -AsHash
    foreach ($state in $StateLabels.Keys) {
        if ($jobs.ContainsKey($state)) {
            "$($StateLabels[$state])$($jobs[$state].Count)"
        }
    }
}
