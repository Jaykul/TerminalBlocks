@{

# Script module or binary module file associated with this manifest.
RootModule = 'TerminalBlocks.psm1'

# Version number of this module.
ModuleVersion = '1.0.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '8a86c3c8-e6d8-4413-8158-a8892cbc16cb'

# Author of this module
Author = 'Joel Bennett'

# Company or vendor of this module
CompanyName = 'HuddledMasses.org'

# Copyright statement for this module
Copyright = '(c) 2022 Joel Bennett. All rights reserved.'

# Description of the functionality provided by this module
Description = 'PowerShell Native Prompt Blocks'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1.0'

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @("PowerLine.types.ps1xml")

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @("TerminalBlocks.format.ps1xml")

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @( "lib\TerminalBlocks.dll" )

RequiredModules = @(
    # Make sure we get the fixed version of Metadata
    @{ModuleName="Metadata";      ModuleVersion="1.5.7"}
    @{ModuleName="Configuration"; ModuleVersion="1.5.1"}
    @{ModuleName="Pansies";       ModuleVersion="2.6.0"}
)
# RequiredAssemblies = "lib\PowerLine.dll"

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @()

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("Prompt", "ANSI", "VirtualTerminal", "EzTheme")

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/Jaykul/TerminalBlocks/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Jaykul/TerminalBlocks'

        # A URL to an icon representing this module.
        # IconUri = ''
        Prerelease = ''

        # ReleaseNotes of this module
        ReleaseNotes = '
        ## 1.2.0

        Add support for separate cap backgrounds, so you can match the blocks on both ends of "bar" when bar has caps on both sides: <foo<bar>baz>. Requires calling .ToString(true, leftBackground, rightBackground)

        ## 1.1.0

        The major feature in this release is the ability to detect (and show) errors.

        1. Add Capture errors by caching .GetPowerShell() and calling .Invoke() on it
        2. Add HadErrors and Streams to TerminalBlocks so you can access that.

        ### In addition, there are a couple new commands to expose static properties

        3. Add Test-Elevation - true if PowerShell is elevated
        4. Add Test-Success - returns [PoshCode.TerminalBlock]::LastSuccess...
           Note that you _must_ set this in your prompt function, or it will always be $true
        5. Fix encoding bug in Show-ElapsedTime in Windows PowerShell
        '
    } # End of PSData hashtable
} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

