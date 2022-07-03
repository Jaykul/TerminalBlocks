using namespace System.Management.Automation.Language
using namespace System.Collections.Generic

class TextReplace {
    [int]$StartOffset = 0
    [int]$EndOffset = 0
    [string]$Text = ''
}

class ParameterPosition {
    [string]$Name
    [int]$StartOffset
    [string]$Text
}

# Should be called on a block to extract the (first) parameters from that block
class ParameterExtractor : AstVisitor {
    [ParameterPosition[]]$Parameters = @()
    [int]$InsertLineNumber = -1
    [int]$InsertColumnNumber = -1
    [int]$InsertOffset = -1

    ParameterExtractor([Ast]$Ast) {
        $ast.Visit($this)
    }

    [AstVisitAction] VisitParamBlock([ParamBlockAst]$ast) {
        if ($Ast.Parameters) {
            $Text = $ast.Extent.Text -split "\r?\n"

            $FirstLine = $ast.Extent.StartLineNumber
            $NextLine = 1
            $this.Parameters = @(
                foreach ($parameter in $ast.Parameters | Select-Object Name -Expand Extent) {
                    [ParameterPosition]@{
                        Name = $parameter.Name
                        StartOffset = $parameter.StartOffset
                        Text =  if (($parameter.StartLineNumber - $FirstLine) -ge $NextLine) {
                                    Write-Verbose "$($Parameter.Name) By Line"
                                    # Take lines after the last parameter
                                    $Lines = @($Text[$NextLine..($parameter.EndLineNumber - $FirstLine)].Where{![string]::IsNullOrWhiteSpace($_)})
                                    # If the last line extends past the end of the parameter, trim that line
                                    if ($Lines.Length -gt 0 -and $parameter.EndColumnNumber -lt $Lines[-1].Length) {
                                        $Lines[-1] = $Lines[-1].SubString($parameter.EndColumnNumber)
                                    }
                                    # Don't return the commas, we'll add them back later
                                    ($Lines -join "`n").TrimEnd(",")
                                } else {
                                    Write-Verbose "$($Parameter.Name) By Text $($parameter.StartLineNumber) - $FirstLine = $($parameter.StartLineNumber - $FirstLine)"
                                    $parameter.Text.TrimEnd(",")
                                }
                    }
                    $NextLine = 1 + $parameter.EndLineNumber - $FirstLine
                }
            )

            $this.InsertLineNumber = $ast.Parameters[-1].Extent.EndLineNumber
            $this.InsertColumnNumber = $ast.Parameters[-1].Extent.EndColumnNumber
            $this.InsertOffset = $ast.Parameters[-1].Extent.EndOffset
        } else {
            $this.InsertLineNumber = $ast.Extent.EndLineNumber
            $this.InsertColumnNumber = $ast.Extent.EndColumnNumber - 1
            $this.InsertOffset = $ast.Extent.EndOffset - 1
        }
        return [AstVisitAction]::StopVisit
    }
}

class MergeParameter : AstVisitor {
    [List[TextReplace]]$Replacements = @()
    [ScriptBlock]$Parameters = {}
    [ScriptBlock]$Where = {$true}

    [System.Management.Automation.HiddenAttribute()]
    [ParameterExtractor]$Additional

    [ParameterExtractor]GetAdditional() {
        if(!$this.Additional) {
            $this.Additional = $this.Parameters.Ast
        }
        return $this.Additional
    }

    [AstVisitAction] VisitFunctionDefinition([FunctionDefinitionAst]$ast) {
        if (!$ast.Where($this.Where)) {
            return [AstVisitAction]::SkipChildren
        }
        $Existing = [ParameterExtractor]$ast

        $ToAdd = $this.GetAdditional().Parameters.Where{ $_.Name -notin $Existing.Parameters.Name }
        $Replacement = [TextReplace]@{
            StartOffset = $Existing.InsertOffset
            EndOffset   = $Existing.InsertOffset
            Text        = if ($Existing.Parameters.Count -gt 0) {
                            ",`n" + ($ToAdd.Text -join ",`n")
                        } else {
                            "`n" + ($ToAdd.Text -join ",`n")
                        }
        }

        Write-Verbose "ToAdd: $($Replacement | Out-String)"

        $this.Replacements.Add($Replacement)
        return [AstVisitAction]::SkipChildren
    }
}

class MergeBlocks : AstVisitor {
    [List[TextReplace]]$Replacements = @()
    [ScriptBlock]$Where = {$true}
    [ScriptBlock]$Template

    [System.Management.Automation.HiddenAttribute()]
    [ScriptBlockAst]$TemplateBody

    [ScriptBlockAst]GetTemplateBody() {
        if (!$this.TemplateBody) {
            $this.TemplateBody = $(
                if ($this.Template.Ast -is [ScriptBlockAst]) {
                    $this.Template.Ast
                } elseif ($this.Template.Ast.Body -is [ScriptBlockAst]) {
                    $this.Template.Ast.Body
                } else {
                    Write-Warning "No such body."
                }
            )
        }

        return $this.TemplateBody
    }

    # The [Alias(...)] attribute on functions matters, but we can't export aliases that are defined inside a function
    [AstVisitAction] VisitFunctionDefinition([FunctionDefinitionAst]$ast) {
        if (!$ast.Where($this.Where)) {
            return [AstVisitAction]::SkipChildren
        }

        if ($ast.Body.BeginBlock -and $this.GetTemplateBody().BeginBlock) {
            $BeginExtent = $ast.Body.BeginBlock.Extent
            $BeginBlockText = $BeginExtent.Text -replace "^[\s\r\n]*begin[\s\r\n]*{[\s\r\n]*|[\s\r\n]*}[\s\r\n]*$","`n"

            $Replacement = [TextReplace]@{
                StartOffset = $BeginExtent.StartOffset
                EndOffset   = $BeginExtent.EndOffset
                Text        = "`n" + $this.GetTemplateBody().BeginBlock.Extent.Text.Replace("existingbegin", $BeginBlockText)
            }

            $this.Replacements.Add( $Replacement )
        } else {
            Write-Verbose "$($ast.Name) Missing BeginBlock"
        }

        if ($ast.Body.ProcessBlock -and $this.GetTemplateBody().ProcessBlock) {
            $ProcessExtent = $ast.Body.ProcessBlock.Extent
            $ProcessBlockText = $ProcessExtent.Text -replace "^[\s\r\n]*process[\s\r\n]*{[\s\r\n]*|[\s\r\n]*}[\s\r\n]*$","`n"

            $Replacement = [TextReplace]@{
                StartOffset = $ProcessExtent.StartOffset
                EndOffset   = $ProcessExtent.EndOffset
                Text        = "`n" + $this.GetTemplateBody().ProcessBlock.Extent.Text.Replace("existingprocess", $ProcessBlockText)
            }

            $this.Replacements.Add( $Replacement )
        } else {
            Write-Verbose "$($ast.Name) Missing ProcessBlock"
        }

        if ($ast.Body.EndBlock -and $this.GetTemplateBody().EndBlock) {
            # The end block is a problem because it frequently contains the param block, which must be left alone
            $EndBlock = $ast.Body.EndBlock

            $EndBlockText = $EndBlock.Extent.Text
            $StartOffset = $EndBlock.Extent.StartOffset
            if ($EndBlock.UnNamed -and $ast.Body.ParamBlock.Extent.Text) {
                $EndBlockText = $EndBlock.Extent.Text -replace ([regex]::Escape($ast.Body.ParamBlock.Extent.Text))
                $StartOffset = $ast.Body.ParamBlock.Extent.EndOffset
            } else {
                # Trim the `end {` ... `}` because we're inserting it into the template end
                $EndBlockText = $EndBlock.Extent.Text -replace "^[\s\r\n]*end[\s\r\n]*{[\s\r\n]*|[\s\r\n]*}[\s\r\n]*$","`n"
            }

            $Replacement = [TextReplace]@{
                StartOffset = $StartOffset
                EndOffset   = $EndBlock.Extent.EndOffset
                Text        = "`n" + $this.GetTemplateBody().EndBlock.Extent.Text.Replace("existingend", $EndBlockText)
            }

            $this.Replacements.Add( $Replacement )
        } else {
            Write-Verbose "$($ast.Name) Missing EndBlock"
        }

        return [AstVisitAction]::SkipChildren
    }
}

function Merge-FunctionParameter {
    [CmdletBinding()]
    param(
        # The name of functions to add parameters to. Supports wildcards.
        [string[]]$ToWhere,

        # The name of a function (or script) to pull parameters from
        # E.g. (Get-Command Foo).ScriptBlock
        [string]$From
    )
    process {
        $RootModulePath = Join-Path $Module.ModuleBase $Module.RootModule

        #! We can't reuse the AST because it needs to be updated after we change it
        #! But we can handle this in a wrapper
        $Ast = &(Get-Module ModuleBuilder) {
            param($Path)
            (ConvertToAst $Path).Ast
        } -Path $RootModulePath

        $function = [MergeParameter]@{
            Where      = { $Func = $_; $ToWhere.ForEach({ $Func.Name -like $_ }) -contains $true }.GetNewClosure()
            Parameters = (Get-Command $From).ScriptBlock
        }

        $Ast.Visit($function)

        #! Process replacements from the bottom up, so the line numbers work
        $Content = Get-Content $RootModulePath -Raw
        foreach ($replacement in $function.Replacements | Sort-Object StartOffset -Descending) {
            $Content = $Content.Insert($replacement.StartOffset, $replacement.Text)
        }
        Set-Content $RootModulePath $Content
    }
}

function Merge-Template {
    [CmdletBinding()]
    param(
        # The name of functions to add parameters to. Supports wildcards.
        [string[]]$ToWhere,

        # The name of a function (or script) to pull parameters from
        # E.g. (Get-Command Foo).ScriptBlock
        [string]$From
    )
    process {
        $RootModulePath = Join-Path $Module.ModuleBase $Module.RootModule

        #! We can't reuse the AST because it needs to be updated after we change it
        #! But we can handle this in a wrapper
        $Ast = &(Get-Module ModuleBuilder) {
            param($Path)
            (ConvertToAst $Path).Ast
        } -Path $RootModulePath

        $function = [MergeBlocks]@{
            Where      = { $Func = $_; $ToWhere.ForEach({ $Func.Name -like $_ }) -contains $true }.GetNewClosure()
            Template   = (Get-Command $From).ScriptBlock
        }

        $Ast.Visit($function)

        #! Process replacements from the bottom up, so the line numbers work
        $Content = Get-Content $RootModulePath -Raw
        foreach ($replacement in $function.Replacements | Sort-Object StartOffset -Descending) {
            $Content = $Content.Remove($replacement.StartOffset, ($replacement.EndOffset - $replacement.StartOffset)).Insert($replacement.StartOffset, $replacement.Text)
        }
        Set-Content $RootModulePath $Content
    }
}
