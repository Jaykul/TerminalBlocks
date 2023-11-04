#requires -Module Configuration, @{ ModuleName = "ModuleBuilder"; ModuleVersion = "1.6.0" }, @{ ModuleName = "Pansies"; ModuleVersion = "2.4.0" }

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
    if ($semver = gitversion -showvariable NuGetVersion) {
        $null = $PSBoundParameters.Add("SemVer", $SemVer)
    }
}

try {
    if (!$SkipBinaryBuild) {
        Write-Host "## Compiling binary module" -ForegroundColor Cyan
        # dotnet restore
        dotnet publish -c $Configuration -o "$PSScriptRoot/lib" | Write-Host -ForegroundColor DarkGray
        # We can't ship the Management DLLs because they're in PowerShell
        Get-ChildItem $Folder -Filter System.Management.* -Recurse | Remove-Item
    }

    $null = $PSBoundParameters.Remove("Configuration")
    $null = $PSBoundParameters.Remove("SkipBinaryBuild")
    $Module = Build-Module @PSBoundParameters -Passthru
    $Folder = Split-Path $Module.Path
    $Folder

} finally {
    Pop-Location -StackName BuildModuleScript
}
