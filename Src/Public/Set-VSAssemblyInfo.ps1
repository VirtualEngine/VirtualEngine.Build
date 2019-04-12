function Set-VSAssemblyInfo {
<#
    .SYNOPSIS
        Updates assembly properties of a Visual Studio AssemblyInfo file.
    .DESCRIPTION
        Sets the AssemblyVersion and/or AssemblyFileVersion attriutes in the
        file path(s) specified.
    .NOTES
        Adapted from Luis Rocha's code that can be found at http://www.luisrocha.net/2009/11/setting-assembly-version-with-windows.html
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='Path')]
    param (
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')]
        [System.String[]] $Path = (Get-Location -PSProvider FileSystem),

        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')]
        [System.String] $Version,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')]
        [System.String] $FileVersion,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Title,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Description,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Company,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Product,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Copyright,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Trademark,

        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Culture
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            for ($i = 0; $i -lt $Path.Length; $i++) {
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        } else {
            $Path = $LiteralPath;
        } # end if
        [ref] $null = $PSBoundParameters.Remove('Path');
        [ref] $null = $PSBoundParameters.Remove('LiteralPath');

    } # end begin
    process {

        foreach ($resolvedPath in $Path) {
            (Get-Content -Path $resolvedPath -Encoding Unicode) |
                Update-VSAssemblyInfo @PSBoundParameters |
                    Set-Content -Path $resolvedPath -Encoding Unicode;
        } # end foreach

    } # end process
} #end function
