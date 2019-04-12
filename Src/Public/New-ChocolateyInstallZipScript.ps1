function New-ChocolateyInstallZipScript {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file for zipped
            Powershell script deployment.
        .DESCRIPTION
            This cmdlet copies ChocolateyInstall.ps1 and ChocolateyUninstall.ps1
            files to the destination path specified for a zipped Powershell script
            deployment.

            These files permit installation of the Powershell module into the (by
            default) user's \WindowsPowershell directory, or the machine C:\Program
            Files\WindowsPowershell\ directory with the '-params allusers'
            installation parameter.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
        [Parameter(Mandatory = $true)] [System.String] $Path,
        ## Chocolatey package name, i.e. VirtualEngine.Build
        [Parameter(Mandatory = $true)] [System.String] $PackageName,
        ## Zip download Uri
        [Parameter(Mandatory = $true)] [System.String] $Uri
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstallZipScript -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyUninstallZipScript -replace '\{packagename\}' |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function
