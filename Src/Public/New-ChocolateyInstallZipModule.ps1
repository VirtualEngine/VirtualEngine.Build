function New-ChocolateyInstallZipModule {
<#
    .SYNOPSIS
        Creates a new ChocolateyInstall and ChocolateyUninstall file for zipped Powershell module installation.
    .DESCRIPTION
        This cmdlet copies ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files to the destination
        path specified for a zipped Powershell module installation.

        These files permit installation of the Powershell module into the (by default)
        user's WindowsPowershell\Modules path, or the machine C:\Program Files\WindowsPowershell
        \Module directory with the '-params allusers' installation parameter.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
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
        $chocolateyInstallZipModule -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}',
            $Uri -replace '\{checksum\}', $Checksum -replace '\{checksumtype\}', $ChecksumType |
                Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyUninstallZipModule -replace '\{packagename\}', $PackageName |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function
