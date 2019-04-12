function Update-VSAssemblyInfo {
<#
    .SYNOPSIS
        Updates assembly properties of a Visual Studio AssemblyInfo file.
    .DESCRIPTION
        This is an internal function called by the Set-VSAssemblyInfo cmdlet.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String[]] $InputObject,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')]
        [System.String] $Version,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')]
        [System.String] $FileVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Title,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Company,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Product,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Copyright,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Trademark,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $Culture
    )
    begin {

        $matches = @{};
        foreach ($parameter in $PSBoundParameters.Keys |
            Where-Object { @('InputObject','Verbose','Debug','ErrorAction') -notcontains $PSItem; }) {
                $replace = 'Assembly{0}("{1}")' -f $parameter, $PSBoundParameters[$parameter];
                $match = 'Assembly{0}\(".*"\)' -f $parameter;
                Write-Verbose ('Adding regex pattern match for ''{0}'' to ''{1}''.' -f $match, $replace);
                [Ref] $null = $matches.Add($match, $replace);
        }

    } #end begin
    process {

        $InputObject | ForEach-Object {
            foreach ($match in $matches.Keys) {
                $PSItem = $PSItem -replace $match, $matches[$match];
            }
            $PSItem;
        } #end foreach-object

    } #end process
} #end function
