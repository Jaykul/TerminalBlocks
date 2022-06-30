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

    Remove-Module $Module.Name -Force -ErrorAction SilentlyContinue
    Import-Module $Module.Path

    $FilePath = Join-Path $Module.ModuleBase $Module.RootModule
    $ModuleContent = Get-Content -Path $FilePath -raw

    $NewTerminalBlock = Get-Command -Name New-TerminalBlock -CommandType Function # -Module $Module.Name
    foreach ($name in $Module.ExportedFunctions.Keys -match "^Show-") {
        $Command = Get-Command -Name $Name -CommandType Function -Module $Module.Name | Select-Object -First 1

        $Before = [regex]::Escape(($Command.ScriptBlock.ToString().Split("param(", 2)[1]))

        $CommandParameters = [System.Management.Automation.ProxyCommand]::GetParamBlock($Command)
        $After = "$(if ($CommandParameters) { "$CommandParameters," })
        $(@([System.Management.Automation.ProxyCommand]::GetParamBlock($NewTerminalBlock) -split '\${RecallPosition},[\s\r\n]+')[1])
    )
    `$PSBoundParameters['Content'] = { # $($Command.Name)
    $($Command.ScriptBlock)
    }.GetNewClosure()

    # toss all the parameters that came from the command
    foreach (`$name in `$Command.Parameters.Keys) {
        `$null = `$PSBoundParameters.Remove(`$name)
    }
    [PoshCode.TerminalBlock]`$PSBoundParameters
"
        # $ModuleContent = $ModuleContent -replace $Before, $After
        $M = Select-String -Pattern $Before -InputObject $ModuleContent |
            Select-Object -First 1 -Expand Matches
        $ModuleContent = $ModuleContent.Remove($m.Index, $m.Length).Insert($m.Index, $after)
    }
    Set-Content $FilePath $ModuleContent
#>

    $Folder = Split-Path $Module.Path

    if (!$SkipBinaryBuild) {
        Write-Host "## Compiling binary module" -ForegroundColor Cyan

        # dotnet restore
        dotnet publish -c $Configuration -o "$($Folder)\lib" | Write-Host -ForegroundColor DarkGray
        # We don't need to ship any of the System DLLs because they're all in PowerShell
        Get-ChildItem $Folder -Filter System.* -Recurse | Remove-Item
    }

    $Folder

} finally {
    Pop-Location -StackName BuildModuleScript
}
