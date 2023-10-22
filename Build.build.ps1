<#
.SYNOPSIS
    ./project.build.ps1
.EXAMPLE
    Invoke-Build
.NOTES
    0.5.0 - Parameterize
    Add parameters to this script to control the build
#>
[CmdletBinding()]
param(
    # dotnet build configuration parameter (Debug or Release)
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    # Add the clean task before the default build
    [switch]$Clean,

    # Collect code coverage when tests are run
    [switch]$CollectCoverage,

    # Which projects to build
    [Alias("Projects")]
    $dotnetProjects = @(),

    # Which projects are test projects
    [Alias("TestProjects")]
    $dotnetTestProjects = @(),

    # Further options to pass to dotnet
    [Alias("Options")]
    $dotnetOptions = @{
        "-verbosity" = "minimal"
        # "-runtime" = "linux-x64"
    }
)
$InformationPreference = "Continue"

$Tasks = "Tasks", "../Tasks", "../../Tasks" | Convert-Path -ErrorAction Ignore | Select-Object -First 1

## Self-contained build script - can be invoked directly or via Invoke-Build
if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    & "$Tasks/_Bootstrap.ps1"

    Invoke-Build -File $MyInvocation.MyCommand.Path @PSBoundParameters -Result Result

    if ($Result.Error) {
        $Error[-1].ScriptStackTrace | Out-String
        exit 1
    }
    exit 0
}

## The first task defined is the default task. Put the right values for your project type here...
if ($dotnetProjects) {
    if ($Clean) {
        Add-BuildTask CleanBuild Clean, GitVersion, DotNetRestore, DotNetBuild, DotNetTest, DotNetPublish
    } else {
        Add-BuildTask Build GitVersion, DotNetRestore, DotNetBuild, DotNetTest, DotNetPublish
    }
} else {
    if ($Clean) {
        Add-BuildTask CleanBuild Clean, GitVersion, PSModuleRestore, PSModuleBuild, PSModuleTest, PSModulePublish
    } else {
        Add-BuildTask Build GitVersion, PSModuleRestore, PSModuleBuild, PSModuleTest, PSModulePublish
    }
}

## Initialize the build variables, and import shared tasks, including DotNet tasks
. "$Tasks/_Initialize.ps1" -PowerShell
