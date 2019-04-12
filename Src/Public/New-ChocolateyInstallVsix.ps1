function New-ChocolateyInstallVsix {
<#
    .SYNOPSIS
        Creates a new ChocolateyInstall file for a Visual Studio VSIX installation.
    .DESCRIPTION
        This cmdlet copies only ChocolateyInstall.ps1 file to the destination
        path specified for a Visual Studio extension installation.

        This file installs the Visual Studio plugin in the most recent Visual Studio
        installation.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        ## Chocolatey package name, i.e. VirtualEngine.Build
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $PackageName,

        ## Zip download Uri
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Uri,

        ## File checksum
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Checksum,

        ## File checksum type
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('md5','sha1','sha256','sha512')]
        [System.String] $ChecksumType
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstallVsix -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}',
            $Uri -replace '\{checksum\}', $Checksum -replace '\{checksumtype\}', $ChecksumType |
                Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
    } #end process
} #end function New-ChocolateyInstallModule
