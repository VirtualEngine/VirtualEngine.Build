function Get-ModuleManifestProperty {
<#
    .SYNOPSIS
        Gets a module manifest's property.
    .DESCRIPTION
        The Get-ModuleManifestProperty cmdlet gets a individual property from a PowerShell module's manifest (.psd1) file.
    .PARAMETER Path
        The file path to the module's manifest (.psd1) file.
    .EXAMPLE
        Get-ModuleManifestProperty -Path .\example.psd1 -Property 'ModuleName'

        This command gets the 'ModuleName' property value from the module manifest's .\example.psd1 file.
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.String])]
    param(
        # One or more file paths
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')]
        [System.String[]] $Path = (Get-Location -PSProvider FileSystem),

        # One or literal file paths
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath,
        # Module manifest property to retrieve.

        [Parameter(Position=1, Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'Module manifest property to return.')]
        [ValidateSet('Author','ClrVersion','CompanyName','Copyright','Definition','Description','DotNetFrameworkVersion','ExportedAliases',
            'ExportedCmdlets','ExportedCommands','ExportedFormatFiles','ExportedFunctions','ExportedTypeFiles','ExportedVariables',
            'ExportedWorkflows','FileList','Guid','HelpInfoUri','LogPipelineExectuionDetails','ModuleBase','ModuleList','ModuleType',
            'Name','NestedModules','OnRemove','Path','PowerShellHostName','PowerShellHostVersion','PowerShellVersion','Prefix',
            'PrivateData','ProcessorArchitecture','RequiredAssemblies','RootModule','Scripts','SessionState','Version')]
        [System.String] $Property,

        # Default value to return if the property is not found.
        [Parameter(Position = 2, ValueFromPipelineByPropertyName, HelpMessage='Default value to return if the property is not found.')]
        [AllowNull()]
        [System.String] $Default = $null
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            $Path = $LiteralPath;
        } # end if

    } #end begin
    process {

        foreach ($resolvedPath in $Path) {
            ## Get the hashtable of module manifest key/value pairs
            $moduleManifest = Get-ModuleManifest -Path $Path;
            if ($null -eq $moduleManifest.$Property) {
                return $Default;
            }
            else {
                return $moduleManifest.$Property;
            }
        } #end foreach

    } #end process
} #end function
