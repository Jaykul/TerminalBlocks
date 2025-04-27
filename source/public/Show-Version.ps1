function Show-Version {
    <#
        .SYNOPSIS
            Gets Version information about PowerShell and more
        .DESCRIPTION
            This function lets you get the various "version" information in a single output.

            By default, it only shows the "Shell" version, which is just $PSVersionTable.PSVersion
        .EXAMPLE
            Show-Version System, Shell -Label -Separator '' -BackgroundColor White -ForegroundColor Black
            | % ToString
    #>
    [OutputType([string], [array])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param(
        # The version to show.
        # The "OS" version is *just* the OS name
        # The "System" version includes the OS Name and Release (and sometimes more)
        # The old "OSVersion" is now "Release" which is also known as the "productVersion" and is part of the "System" version.
        # By default returns the System, Kernel, .NET, and PowerShell versions.
        [ValidateSet("OS", "System", "Release", "Build", "Kernel", ".NET", "PowerShell", "Host")]
        [string[]]$Component = ("System", "Kernel", ".NET", "PowerShell"),

        # Whether to include the label for each component (defaults to $true when no $Component is specified, otherwise $false)
        [switch]$Label
    )
    end {
        if ($PSBoundParameters.Count -eq 0) {
            $Label = $true
        }
        if (!$script:OperatingSystem) {
            $script:OperatingSystem = &(Get-Module TerminalBlocks) { GetOperatingSystem }
        }
        @(
            foreach ($Component in $Component) {
                @(
                    if ($Label) {
                        $Component + ":"
                    }
                    switch ($Component) {
                        "Host" {
                            $Host.Version.ToString()
                        }
                        "PowerShell" {
                            $PSVersionTable.PSVersion.ToString()
                        }
                        ".NET" {
                            [Environment]::Version.ToString()
                        }
                        "Kernel" {
                            $script:OperatingSystem.KernelVersion
                        }
                        "OS" {
                            $script:OperatingSystem.Name
                        }
                        "System" {
                            $script:OperatingSystem.System
                        }
                        "Release" {
                            $script:OperatingSystem.Release
                        }
                        "Build" {
                            $script:OperatingSystem.BuildNumber
                        }
                    }
                ) -join " "
            }
        )
    }
}
