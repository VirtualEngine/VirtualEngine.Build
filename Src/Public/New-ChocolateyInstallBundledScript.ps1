function New-ChocolateyInstallBundledScript {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file for Powershell script
            deployment.
        .DESCRIPTION
            This cmdlet copies a ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 file to the
            destination path specified.

            These files permit installation into the user's Documents\WindowsPowershell folder
            (by default) or into the %ProgramFiles%\WindowsPowershell folder with the '-params
            allusers' installation parameter.

            By default any *.nupkg or *.nuspec files and the \tools directory are excluded.
        .NOTES
            This cmdlet does not permit uninstallation of Powershell scripts - leaving the
            file intact - just in case of modification.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
        [Parameter(Mandatory = $true)] [System.String] $Path,
        ## Files to exclude from the package deployment
        [Parameter()] [System.String[]] $Exclude = @('*.nuspec','*.nupkg','tools')
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstallBundleScript -replace '\{exclude\}', [System.String]::Join("','", $Exclude) |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyUninstallBundleScript |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function
