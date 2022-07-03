#requires -Module Configuration, @{ ModuleName = "ModuleBuilder"; ModuleVersion = "2.0.0" }, Pansies

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet("Release", "Debug")]
    $Configuration = "Release",

    # The ModuleBuilder target (defaults to "CleanBuild")
    $Target = "CleanBuild",

    # Skip building the assembly
    [switch]$SkipBinaryBuild,

    # A specific folder to build into
    $OutputDirectory,

    # The version of the output module
    [Alias("ModuleVersion", "Version")]
    [string]$SemVer
)

# Sanitize parameters to pass to Build-Module
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot -StackName BuildModuleScript

if (-not $Semver -and (Get-Command gitversion -ErrorAction Ignore)) {
    if ($semver = gitversion -showvariable SemVer) {
        $null = $PSBoundParameters.Add("SemVer", $SemVer)
    }
}

try {
    $null = $PSBoundParameters.Remove("Configuration")
    $null = $PSBoundParameters.Remove("SkipBinaryBuild")
    $Module = Build-Module @PSBoundParameters -Passthru

    . .\source\Generators\ModuleBuilderExtensions.ps1

    $Folder = Split-Path $Module.Path
    if (!$SkipBinaryBuild) {
        Write-Host "## Compiling binary module" -ForegroundColor Cyan

        # dotnet restore
        dotnet publish -c $Configuration -o "$($Folder)\lib" | Write-Host -ForegroundColor DarkGray
        # We don't need to ship any of the System DLLs because they're all in PowerShell
        Get-ChildItem $Folder -Filter System.* -Recurse | Remove-Item
    }
    $Folder
    $FilePath = Join-Path $Module.ModuleBase $Module.RootModule

    # NewTerminalBlock has the common TerminalBlock parameters and implementation
    . .\source\Generators\NewTerminalBlock.ps1
    Merge-FunctionParameter "Show-*", "New-TerminalBlock" NewTerminalBlock
    Merge-Template "Show-*", "New-TerminalBlock" NewTerminalBlock

    # TracingAndErrorHandling has common Write-Information and try/catch
    . .\source\Generators\TracingAndErrorHandling.ps1
    Merge-Template "*" TracingAndErrorHandling

} finally {
    Pop-Location -StackName BuildModuleScript
}
