if (!$ExecutionContext.SessionState.Module) {
    [PoshCode.TerminalBlocks.Block]::GlobalSessionState = $ExecutionContext.SessionState
}
