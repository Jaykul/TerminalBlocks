function TracingAndErrorHandling {
    [CmdletBinding()]
    param()
    begin {
        Write-Information "Enter $($PSCmdlet.MyInvocation.MyCommand.Name)" -Tags "BeginBlock", "Enter"
        try {
            existingbegin
        } catch {
            Write-Information $_ -Tags "BeginBlock", "Exception", "Unhandled"
            throw
        } finally {
            Write-Information "Leave $($PSCmdlet.MyInvocation.MyCommand.Name)" -Tags "BeginBlock", "Leave"
        }
    }
    process {
        Write-Information "Enter $($PSCmdlet.MyInvocation.MyCommand.Name)" -Tags "ProcessBlock", "Enter"
        try {
            existingprocess
        } catch {
            Write-Information $_ -Tags "ProcessBlock", "Exception", "Unhandled"
            throw
        } finally {
            Write-Information "Leave $($PSCmdlet.MyInvocation.MyCommand.Name)" -Tags "ProcessBlock", "Leave"
        }
    }
    end {
        Write-Information "Enter $($PSCmdlet.MyInvocation.MyCommand.Name)" -Tags "EndBlock", "Enter"
        try {
            existingend
        } catch {
            Write-Information $_ -Tags "EndBlock", "Exception", "Unhandled"
            throw
        } finally {
            Write-Information "Leave $($PSCmdlet.MyInvocation.MyCommand.Name)" -Tags "EndBlock", "Leave"
        }
    }
}
