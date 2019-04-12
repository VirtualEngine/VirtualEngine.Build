function Set-NuspecProperty {
<#
    .SYNOPSIS
        Set the version number in a .nuspec file
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Version] $Version
    )
    process
    {
        $nuspecPath = (Resolve-Path -Path $Path).Path
        $nuspec = [System.Xml.XmlDocument] (Get-Content -Path $nuspecPath -Raw)

        if ($PSBoundParameters.ContainsKey('Version'))
        {
            $nuspec.Package.MetaData.Version = $Version.ToString()
        }

        if ($PSCmdlet.ShouldProcess($nuspecPath)) {
            $nuspec.Save($nuspecPath)
        }
    } #end process
} #end function
