# Use this file to override the default parameter values used by the `Build-Module`
# command when building the module (see `Get-Help Build-Module -Full` for details).
@{
    ModuleManifest           = "./source/TerminalBlocks.psd1"
    OutputDirectory          = ".."
    VersionedOutputDirectory = $true
    CopyDirectories          = @('examples','TerminalBlocks.format.ps1xml', 'SessionState.ps1')
    Postfix                  = "Footer.ps1"
    Aspects                  = @(
        @{ Function = "Show-*", "New-TerminalBlock"; Action = "AddParameter"; Source = "NewTerminalBlock" }
        @{ Function = "Show-*", "New-TerminalBlock"; Action = "MergeBlocks"; Source = "NewTerminalBlock" }
        @{ Function = "*"; Action = "MergeBlocks"; Source = "TracingAndErrorHandling" }
    )
}
