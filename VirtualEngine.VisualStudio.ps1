function UpdateVSAssemblyInfo {
    <#
        .SYNOPSIS
            Updates
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [System.String[]] $InputObject,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')] [System.String] $Version,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')] [System.String] $FileVersion,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Title,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Description,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Company,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Product,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Copyright,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Trademark,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Culture
    )
    begin {
        $matches = @{};
        foreach ($parameter in $PSBoundParameters.Keys |
            Where-Object { @('InputObject','Verbose','Debug','ErrorAction') -notcontains $PSItem; }) {
                $replace = 'Assembly{0}("{1}")' -f $parameter, $PSBoundParameters[$parameter];
                $match = 'Assembly{0}\(".*"\)' -f $parameter;
                #if ($parameter -ilike '*Version') {
                #    $match = 'Assembly{0}\("[0-9]+(\.([0-9]+|\*)){{1,3}}"\)' -f $parameter;
                #}
                Write-Verbose ('Adding regex pattern match for ''{0}'' to ''{1}''.' -f $match, $replace);
                [Ref] $null = $matches.Add($match, $replace);
        }
        <# if ($AssemblyVersion) { $matches.Add('AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', 'AssemblyVersion("{0}")' -f $AssemblyVersion); }
        if ($FileVersion) { $matches.Add('AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', 'AssemblyFileVersion("{0}")' -f $FileVersion); }
        if ($Title) { $matches.Add('AssemblyTitle\(".+"\)', 'AssemblyTitle("{0}")' -f $Title); }
        if ($Description) { $matches.Add('AssemblyDescription\(".+"\)', 'AssemblyDescription("{0}")' -f $Description); }
        if ($Company) { $matches.Add('AssemblyCompany\(".+"\)', 'AssemblyCompany("{0}")' -f $Company); }
        if ($Product) { $matches.Add('AssemblyProduct\(".+"\)', 'AssemblyProduct("{0}")' -f $Product); }
        if ($Copyright) { $matches.Add('AssemblyCopyright\(".+"\)', 'AssemblyCopyright("{0}")' -f $Copyright); }
        if ($Trademark) { $matches.Add('AssemblyTrademark\(".+"\)', 'AssemblyTrademark("{0}")' -f $Trademark); }
        if ($Culture) { $matches.Add('AssemblyCulture\(".+"\)', 'AssemblyCulture("{0}")' -f $Culture); }
        [Ref] $null = $PSBoundParameters.Remove('InputObject');
        #>
    }
    process {
        $InputObject | ForEach-Object {
            foreach ($match in $matches.Keys) {
                $PSItem = $PSItem -replace $match, $matches[$match];
            }  
            $PSItem;
        } #end foreach-object
    } #end process
} #end function UpdateVSAssemblyInfo

function Set-VSAssemblyInfo {
    <#
        .SYNOPSIS
            Updates assembly properties of a Visual Studio AssemblyInfo file.
        .DESCRIPTION
            Function description.
        .EXAMPLE
            Function example.
        .NOTES
            Adapted from Luis Rocha's code that can be found at http://www.luisrocha.net/2009/11/setting-assembly-version-with-windows.html
    #>
    [CmdletBinding(DefaultParameterSetName='Path')]
    #[OutputType([PSModuleInfo])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String[]] $Path = (Get-Location -PSProvider FileSystem),
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')] [System.String] $Version,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')] [System.String] $FileVersion,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Title,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Description,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Company,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Product,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Copyright,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Trademark,
        [Parameter(ValueFromPipelineByPropertyName = $true)] [System.String] $Culture
    )
    begin {  
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            for ($i = 0; $i -lt $Path.Length; $i++) { 
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        } else {
            $Path = $LiteralPath;
        } # end if
        [Ref] $null = $PSBoundParameters.Remove('Path');
        [Ref] $null = $PSBoundParameters.Remove('LiteralPath');
    } # end begin
    process {
        foreach ($resolvedPath in $Path) {
            #$stringBuilder = New-Object System.Text.StringBuilder;
            (Get-Content -Path $resolvedPath -Encoding Unicode) |
                UpdateVSAssemblyInfo @PSBoundParameters |
                    Set-Content -Path $resolvedPath -Encoding Unicode;
        } # end foreach   
    } # end process
} #end function Set-VSAssemblyVersion
 