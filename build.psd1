# Use this file to override the default parameter values used by the `Build-Module`
# command when building the module (see `Get-Help Build-Module -Full` for details).
@{
    ModuleManifest           = "Source/TerminalBlocks.psd1"
    OutputDirectory          = "../"
    VersionedOutputDirectory = $true
    CopyDirectories          = @('examples','TerminalBlocks.format.ps1xml')
    Postfix                  = "Footer.ps1"
}
