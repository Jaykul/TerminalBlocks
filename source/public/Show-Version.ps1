function Show-Version {
    <#
        .SYNOPSIS
            Gets Version information about the current host, PowerShell, and OS
        .DESCRIPTION
            Calls [Environment]::UserName
        .EXAMPLE
            Show-Version OSName, OSVersion, PSVersion -Label -Separator '' -BackgroundColor White -ForegroundColor Black
            | % ToString
    #>
    [OutputType([string])]
    [CmdletBinding(DefaultParameterSetName = "SimpleFormat")]
    param(
        # The version to show (default: PSVersion)
        [ValidateSet("OSName", "OSVersion", "Kernel", "NET", "PSVersion", "Host", "All")]
        [string[]]$Component,

        # Whether to include the label for each component (defaults to $true if $Component is "All")
        [switch]$Label
    )
    end {
        if ($Component -eq "All") {
            $Label = $true
            $Component = "OSName", "OSVersion", "Kernel", "NET", "PSVersion", "Host"
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
                        "PSVersion" {
                            $PSVersionTable.PSVersion.ToString()
                        }
                        "Kernel" {
                            [Environment]::OSVersion.Version.ToString()
                        }
                        "NET" {
                            [Environment]::Version.ToString()
                        }
                        # We may need some help here, because I'm not sure this is enough _everywhere_
                        "OSName" {
                            if (Test-Path /etc/*-release) {
                                $Data = @{}
                                Get-Content /etc/*-release | ConvertFrom-StringData | ForEach-Object { $Data += $_ }
                                @($Data["DISTRIB_ID", "Name", "Id"].Trim(" `t`r`n`"'"))[0]
                            } elseif (Get-Command Get-CimInstance -ErrorAction Ignore) {
                                (Get-CimInstance Win32_OperatingSystem -Property Caption).Caption
                            } elseif ($IsMacOS) {
                                "MacOS"
                            }
                        }
                        "OSVersion" {
                            if (Test-Path /etc/*-release) {
                                $Data = @{}
                                Get-Content /etc/*-release | ConvertFrom-StringData | ForEach-Object { $Data += $_ }
                                @($Data["VERSION_ID", "DISTRIB_RELEASE", "VERSION", "PRETTY_NAME"].Trim(" `t`r`n`"'"))[0]
                            } elseif (Get-Command Get-CimInstance -ErrorAction Ignore) {
                                (Get-CimInstance Win32_OperatingSystem -Property BuildNumber).BuildNumber
                            } elseif ($IsMacOS) {
                                sw_vers -productVersion
                            }
                        }
                    }
                ) -join " "
            }
        ) -join $Separator
    }
}
