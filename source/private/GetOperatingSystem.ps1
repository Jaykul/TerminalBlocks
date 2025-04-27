function GetOperatingSystem {
    <#
        .SYNOPSIS
            Gets the Operating System information of the current system.
    #>
    [CmdletBinding()]
    param()

    if ($script:OperatingSystem) {
        return $script:OperatingSystem
    }

    if ($IsLinux -and (Test-Path /etc/*-release)) {
        # We may need some help here, because I'm not sure this is enough _everywhere_
        $Data = @{}
        Get-Content /etc/*-release | ConvertFrom-StringData | ForEach-Object { $Data += $_ }
        $script:OperatingSystem = [PSCustomObject]@{
            Name          = @($Data["DISTRIB_ID", "NAME", "ID"].Trim(" `t`r`n`"'"))[0]
            System        = @($Data["PRETTY_NAME", "DISTRIB_DESCRIPTION", "NAME"].Trim(" `t`r`n`"'"))[0]
            Release       = @($Data["VERSION_ID", "DISTRIB_RELEASE", "VERSION"].Trim(" `t`r`n`"'"))[0]
            BuildNumber   = @($Data["VERSION_ID", "DISTRIB_RELEASE", "VERSION"].Trim(" `t`r`n`"'"))[0]
            KernelVersion = [Environment]::OSVersion.Version.ToString()
        }
    } elseif ($IsMacOS) {
        $script:OperatingSystem = [PSCustomObject]@{
            Name          = "macOS" # Should this be "Darwin" (i.e. uname -s)?
            System        = "macOS $(uname -s) $(sw_vers -productVersion)"
            Release       = sw_vers -productVersion
            BuildNumber   = sw_vers -buildVersion
            KernelVersion = [Environment]::OSVersion.Version.ToString()
        }
    } elseif (Get-Command Get-CimInstance -ErrorAction Ignore) {
        $OS = Get-CimInstance Win32_OperatingSystem -Property Caption, BuildNumber -ErrorAction Ignore
        $script:OperatingSystem = [PSCustomObject]@{
            Name          = "Windows"
            System        = $OS.Caption -replace "Microsoft "
            Release       = ($OS.Caption -replace "Microsoft Windows " -split " ")[0]
            BuildNumber   = $OS.BuildNumber
            KernelVersion = [Environment]::OSVersion.Version.ToString()
        }
    } elseif (Get-Command uname -ErrorAction Ignore) {
        Write-Verbose "No /etc/*-release but 'uname' command found, using it to get OS information."
        # In case there's a posix system without etc/*-release
        $script:OperatingSystem = [PSCustomObject]@{
            Name          = uname -s
            System        = uname -sr
            Release       = uname -r
            BuildNumber   = uname -r
            KernelVersion = [Environment]::OSVersion.Version.ToString()
        }
    }
    $script:OperatingSystem
}
