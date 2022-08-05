# TerminalBlocks

TerminalBlocks are basically ScriptBlocks with some rendering information for virtual terminals.

When you convert a TerminalBlock to string, it invokes the script and applies foreground and background colors, positioning, alignment, etc.

Right now, I am focusing on prompts, and I have written a handful of functions that output terminal blocks for prompts. The generic one is `New-TerminalBlock` which literally just takes a ScriptBlock and all the properties of a TerminalBlock and combines them. The rest actually involve some code-generation...

## Aspect-oriented function generation

In this module, I have added a [Generators/ModuleBuildExtensions](Generators/ModuleBuilderExtensions.ps1), which I intend to ship in [ModuleBuilder](https://github.com/PoshCode/ModuleBuilder) eventually -- it adds a `Merge-Aspect` function I can call in my build script, and I use that to combine the functions in the `/Generators` folder with the functions in the `/public` folder.

The bottom line is that the **build process** takes the `Show-` functions and combines them with [Generators/NewTerminalBlock](Generators/NewTerminalBlock.ps1) to create a new function where the `end` block of the show function is the scriptblock in the TerminalBlock. Along the way, you get all the parameters from `NewTerminalBlock` as common parameters, and you get error handling and tracing from [Generators/TracingAndErrorHandling](Generators/TracingAndErrorHandling.ps1)

To see it in action, you need to run `./build.ps1` and then compare the files in source/public with the functions in the output `TerminalBlocks.psm1` module.

## Currently available blocks:

- [Show-AzureContext](source/public/Show-AzureContext.ps1) - Shows the current Azure context (i.e. `(Get-AzContext).Name`).
- [Show-DockerContext](source/public/Show-DockerContext.ps1) - shows the current Docker context (i.e. `docker context show`).
- [Show-KubeContext](source/public/Show-KubeContext.ps1) - shows the current Kubernetes context (i.e. `kubectl config current-context`).
- [Show-Date](source/public/Show-Date.ps1) - Shows the current date/time.
- [Show-ElapsedTime](source/public/Show-ElapsedTime.ps1) - shows how long the _last_ command took to run.
- [Show-ErrorCount](source/public/Show-ErrorCount.ps1) - shows how many new errors occurred since the last time this block was run.
- [Show-HistoryId](source/public/Show-HistoryId.ps1) - shows the history ID of the next command to run -- you can tab complete that command later by using #nn{Tab}
- [Show-LastExitCode](source/public/Show-LastExitCode.ps1) - shows the last exit code when the last native command failed.
- [Show-Path](source/public/Show-Path.ps1) - shows the current working directory. There are a lot of options for shortening the path!
- [Show-PoshGitStatus](source/public/Show-PoshGitStatus.ps1) - shows your git status (using posh-git module).









