if (!$ExecutionContext.SessionState.Module) {
    [PoshCode.TerminalBlock]::GlobalSessionState = $ExecutionContext.SessionState
}
