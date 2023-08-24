[CmdletBinding()]
param()

function Get-Data {
    <#
        .SYNOPSIS
            A demo function that outputs objects from begin, process and end
    #>
    [CmdletBinding()]param()
    begin {
        Write-Verbose "$($PSStyle.Background.Green + $PSStyle.Foreground.Black)$(" " * $script:Indent; $script:Indent += 4)ENTER Get-Data (Begin)$($PSStyle.Reset)"
        Write-Debug "  $($PSStyle.Background.Green + $PSStyle.Foreground.Black)$(" " * $script:Indent)Get-Data expecting pipeline input: $($PSCmdlet.MyInvocation.ExpectingInput.ToString())"
        # You can write output from any of the blocks you want
        Write-Warning "$($PSStyle.Background.Green + $PSStyle.Foreground.Black)$(" " * $script:Indent)Get-Data Writes Output 1 from Begin"
        [PSCustomObject]@{
            Name = 'Adam'
            Age  = 30
        }
        Write-Verbose "$($PSStyle.Background.Green + $PSStyle.Foreground.Black)$($script:Indent -= 4; " " * $script:Indent)EXIT  Get-Data (Begin)$($PSStyle.Reset)"
    }
    process {
        Write-Verbose "$($PSStyle.Background.Cyan + $PSStyle.Foreground.Black)$(" " * $script:Indent; $script:Indent += 4)ENTER Get-Data (Process)$($PSStyle.Reset)"
        Write-Debug "  $($PSStyle.Background.Cyan + $PSStyle.Foreground.Black)$(" " * $script:Indent)Get-Data expecting pipeline input: $($PSCmdlet.MyInvocation.ExpectingInput.ToString())"
        # You can write output from all the blocks!
        Write-Warning "$($PSStyle.Background.Cyan + $PSStyle.Foreground.Black)$(" " * $script:Indent)Get-Data Writes Output 2 from Process"
        [PSCustomObject]@{
            Name = 'Barbara'
            Age  = 31
        }
        Write-Verbose "$($PSStyle.Background.Cyan + $PSStyle.Foreground.Black)$($script:Indent -= 4; " " * $script:Indent)EXIT  Get-Data (Process)$($PSStyle.Reset)"
    }
    end {
        Write-Verbose "$($PSStyle.Background.Red + $PSStyle.Foreground.Black)$(" " * $script:Indent; $script:Indent += 4)ENTER Get-Data (End)$($PSStyle.Reset)"
        Write-Debug "  $($PSStyle.Background.Red + $PSStyle.Foreground.Black)$(" " * $script:Indent)Get-Data expecting pipeline input: $($PSCmdlet.MyInvocation.ExpectingInput.ToString())"
        # The end block is the default block, so if you don't take any pipeline input
        # This is where you would *normally* write output
        Write-Warning "$($PSStyle.Background.Red + $PSStyle.Foreground.Black)$(" " * $script:Indent)Get-Data Writes Output 3 from End"
        [PSCustomObject]@{
            Name = 'Chris'
            Age  = 32
        }
        Write-Warning "$($PSStyle.Background.Red + $PSStyle.Foreground.Black)$(" " * $script:Indent)Get-Data Writes Output 4 from End"
        [PSCustomObject]@{
            Name = 'David'
            Age  = 33
        }
        Write-Verbose "$($PSStyle.Background.Red + $PSStyle.Foreground.Black)$($script:Indent -= 4; " " * $script:Indent)EXIT  Get-Data (End)$($PSStyle.Reset)"
    }
}


function Show-Data {
    <#
        .SYNOPSIS
            A demo function that shows how to use the pipeline
    #>
    [OutputType([string])]
    param(
        # The Caps parameter is mandatory, and is not pipeline bound
        # That means you must provide it in-line when you call the function
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Caps,

        # The Name parameter is mandatory, and is pipeline bound by property name
        # Any pipeline input missing a "Name" property would cause an error
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # The Age parameter is pipeline bound by property name, but not mandatory
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Age
    )
    begin {
        Write-Verbose "$($PSStyle.Background.Green + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent); $script:Indent += 4)ENTER Show-Data (Begin)$($PSStyle.Reset)"
        # The begin block is called at the beginning, almost like a constructor.
        # Mandatory parameters that are _not_ pipeline bound are guaranteed to be set here
        # ... it's possible that all your parameters could be set
        # ... ValueFromPipeline doesn't mean ONLY from pipeline
        # You can check whether you're expecting pipeline input or not:
        Write-Debug "  $($PSStyle.Background.Green + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))Show-Data expecting pipeline input: $($PSCmdlet.MyInvocation.ExpectingInput.ToString() + $PSStyle.Reset)"
        Write-Debug "  $($PSStyle.Background.Green + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))Show-Data PSBoundParameters = $($PSBoundParameters.GetEnumerator().ForEach{ $_.Key + ": " + $_.Value } -join ', ')$($PSStyle.Reset)"
        Write-Verbose "$($script:Indent -= 4; $PSStyle.Background.Green + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))EXIT  Show-Data (Begin)$($PSStyle.Reset)"
    }
    process {
        # The process block is always called once
        # But in the case where there is pipeline input, it is called for each input
        Write-Verbose "$($PSStyle.Background.Cyan + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent); $script:Indent += 4)ENTER Show-Data (Process)$($PSStyle.Reset)"
        Write-Debug "  $($PSStyle.Background.Cyan + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))Show-Data expecting pipeline input: $($PSCmdlet.MyInvocation.ExpectingInput.ToString() + $PSStyle.Reset)"
        Write-Debug "  $($PSStyle.Background.Cyan + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))Show-Data PSBoundParameters = $($PSBoundParameters.GetEnumerator().ForEach{ $_.Key + ": " + $_.Value } -join ', ')$($PSStyle.Reset)"

        "                                                 " + $Caps[0] + $Name + " " + $Age + $Caps[-1]
        Write-Verbose "$($script:Indent -= 4; $PSStyle.Background.Cyan + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))EXIT  Show-Data (Process)$($PSStyle.Reset)"
    }
    end {
        # The end block is not called for each item
        Write-Verbose "$($PSStyle.Background.Red + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent); $script:Indent += 4)ENTER Show-Data (End)$($PSStyle.Reset)"
        Write-Debug "  $($PSStyle.Background.Red + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))Show-Data expecting pipeline input: $($PSCmdlet.MyInvocation.ExpectingInput.ToString() + $PSStyle.Reset)"
        # You should therefore not use it to write output based on PIPELINE input
        # ... it would only show the last input
        Write-Debug "  $($PSStyle.Background.Red + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))Show-Data PSBoundParameters = $($PSBoundParameters.GetEnumerator().ForEach{ $_.Key + ": " + $_.Value } -join ', ')$($PSStyle.Reset)"
        # You can use it to put things back the way they were
        # But beware that if anything crashes, this might not get run
        Write-Verbose "$($script:Indent -= 4; $PSStyle.Background.Red + $PSStyle.Foreground.BrightYellow + (" " * $script:Indent))EXIT  Show-Data (End)$($PSStyle.Reset)"
    }
}

filter Limit-Speed {
    <#
        .SYNOPSIS
            A filter is a function where the default block is "process"
            This one has no begin and no end
    #>
    [CmdletBinding()]
    param(
        # How much we slow down the pipeline
        [Parameter(Mandatory)]
        [Alias("Ms", "Milliseconds", "WaitMs")]
        [int]$WaitMilliseconds = 0,

        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    Write-Verbose "$($PSStyle.Background.Cyan + $PSStyle.Foreground.Red)$(" " * $script:Indent; $script:Indent += 4)ENTER Limit-Speed (Process)$($PSStyle.Reset)"
    Write-Debug "  $($PSStyle.Background.Cyan)$($PSStyle.Foreground.Red)$(" " * $script:Indent)Limit-Speed expecting pipeline input: $($PSCmdlet.MyInvocation.ExpectingInput.ToString())"
    Write-Debug "  $($PSStyle.Background.Cyan)$($PSStyle.Foreground.Red)$(" " * $script:Indent)Limit-Speed PSBoundParameters = $($PSBoundParameters.GetEnumerator().ForEach{ $_.Key + ": " + $_.Value } -join ', ')"
    Start-Sleep -Milliseconds $WaitMilliseconds
    Write-Host # Only the "Output" stream goes to the pipeline
    $InputObject
    Write-Verbose "$($script:Indent -= 4; $PSStyle.Background.Cyan + $PSStyle.Foreground.Red + (" " * $script:Indent))EXIT  Limit-Speed (Process)$($PSStyle.Reset)"
}



# For the sake of being able to read the demo, make each of these a different color
$PSStyle.Formatting.Debug = $PSStyle.Foreground.BrightGreen
$PSStyle.Formatting.Verbose = $PSStyle.Foreground.BrightCyan
$PSStyle.Formatting.Warning = $PSStyle.Foreground.BrightYellow
$PSStyle.Formatting.Error = $PSStyle.Foreground.BrightRed
# $PSStyle.Background.Red = "`e[48;2;255;99;71m"

$script:Indent = 0

# Simple demo:
Write-Host "$($PSStyle.Background.Green + $PSStyle.Foreground.Black)BEGIN has a green background...$($PSStyle.Reset)"
Write-Host "$($PSStyle.Background.Cyan + $PSStyle.Foreground.Black)PROCESS has a cyan background...$($PSStyle.Reset)"
Write-Host "$($PSStyle.Background.Red + $PSStyle.Foreground.Black)END has a red background...$($PSStyle.Reset)"

Get-Data -Verbose -WarningAction Ignore | Out-Null

Write-Host
Write-Host
Start-Sleep 2

# With output
Write-Host "$($PSStyle.Background.Yellow + $PSStyle.Foreground.Black)Now Get-Data warns, before each output...$($PSStyle.Reset)"
Read-Host "Press ENTER to continue..."
Get-Data -Verbose | Format-List | Out-Default

Write-Host
Write-Host
Start-Sleep 2
Write-Host "$($PSStyle.Background.Yellow + $PSStyle.Foreground.Black)Now we add a pipeline$($PSStyle.Reset)"
Write-Host "$($PSStyle.Background.Yellow + $PSStyle.Foreground.Black)As we ENTER each block, we indent, so commands that are further down the pipeline will be indented further...$($PSStyle.Reset)"

Write-Host "$($PSStyle.Background.Green + $PSStyle.Foreground.Black)BEGIN has a green background...$($PSStyle.Reset)"
Write-Host "$($PSStyle.Background.Cyan + $PSStyle.Foreground.Black)PROCESS has a cyan background...$($PSStyle.Reset)"
Write-Host "$($PSStyle.Background.Red + $PSStyle.Foreground.Black)END has a red background...$($PSStyle.Reset)"

Write-Host "$($PSStyle.Background.White + $PSStyle.Foreground.Black)Get-Data has black text$($PSStyle.Reset)"
Write-Host "$($PSStyle.Background.White + $PSStyle.Foreground.BrightYellow)Show-Data has yellow text$($PSStyle.Reset)"
Write-Host "$($PSStyle.Background.White + $PSStyle.Foreground.Red)Limit-Speed has red output$($PSStyle.Reset)"
Read-Host "Press ENTER to continue..."


# Get-Data | Show-Data -Caps '', ''
Get-Data -Verbose | Limit-Speed -Ms 800 -Verbose | Show-Data -Caps '', '' -Verbose
