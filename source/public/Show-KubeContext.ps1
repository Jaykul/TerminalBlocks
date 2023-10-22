function Show-KubeContext {
    <#
        .SYNOPSIS
            Shows the current kubectl context
    #>
    [CmdletBinding()]
    param(
        # A string to show before the output. Defaults to "&nf-mdi-ship_wheel; "
        [string]$Prefix = "&nf-mdi-ship_wheel; ",

        # Show more information about the context, like the default namespace.
        # If set, the output will be based on the GoTemplate and will use "kubectl config view --minify" instead of "kubectl config current-context"
        [switch]$Detailed,

        # A JSON Path string to use for the output.
        # This will be passed to: kubectl config view --minify -o jsonpath='...'
        # E.g. "{.contexts[0].name}/{.contexts[0].context.namespace}"
        [string]$JsonPath,

        # The GoTemplate to use for the output.
        # Defaults to a string that shows contextName/namespace if a default namespace is set, but just the context name otherwise.
        # '{{range .contexts}}{{.name}}{{if .context.namespace}}/{{.context.namespace}}{{end}}{{end}}'
        [string]$GoTemplate = '{{range .contexts}}{{.name}}{{if .context.namespace}}/{{.context.namespace}}{{end}}{{end}}'
    )
    if (Get-Command kubectl -ErrorAction Ignore) {
        $Context = if ($JsonPath) {
            kubectl config view --minify -o "jsonpath=$JsonPath"
        } elseif ($Detailed -or $PSBoundParameters.ContainsKey("GoTemplate")) {
            kubectl config view --minify --template $GoTemplate
        } else {
            kubectl config current-context
        }
        if ($Context) {
            $Context
        }
    }
}
