function New-ChocolateyInstallZipPortable {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file for portable installation.
        .DESCRIPTION
            This cmdlet copies a ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 file to the
            destination path specified for a portable executable installation.

            These files permit installation into the (by default) Chocolatey path, or the user's
            Documents folder with the '-params currentuser' installation parameter.
        .NOTES
            This currently relies on a Zip file.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
        [Parameter(Mandatory = $true)] [System.String] $Path,
        ## Chocolatey package name, i.e. VirtualEngine.Build
        [Parameter(Mandatory = $true)] [System.String] $PackageName,
        ## Zip download Uri
        [Parameter(Mandatory = $true)] [System.String] $Uri,
        ## GUI applications to create shims for. See https://github.com/chocolatey/chocolatey/wiki/CreatePackages for batch redirects.
        [Parameter()] [System.String[]] $Shim
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $shims = "'{0}'" -f [System.String]::Join("','", $Shim);
        $chocolateyInstallZipPortable -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri -replace '\{shim\}', $shims |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
    } #end process
} #end function
