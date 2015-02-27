$chocolateyModuleZipInstall = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based Powershell module installations
$moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
if ($env:chocolateyPackageParameters -like '*Scope*' -and $env:chocolateyPackageParameters -like '*AllUsers*') {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
}
Write-Host ('Installing to "{0}".' -f $moduleInstallPath);
Install-ChocolateyZipPackage '{packagename}' '{downloaduri}' "$moduleInstallPath";
'@;

$chocolateyModuleZipUninstall = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Zip-based Powershell module installations
$moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
if ($env:PackageParameters -like '*Scope*' -and $env:PackageParameters -like '*AllUsers') {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
}
Write-Host ('Removing "{0}\{1}".' -f $moduleInstallPath, '{packagename}');
Remove-Item -Path "$moduleInstallPath\{packagename}" -Recurse -Force;
'@;

function New-ChocolateyInstallModule {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file for Powershell module installation.
        .DESCRIPTION
            This cmdlet copies a ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 file to the
            destination path specified.
    #>
    [CmdletBinding()]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
        [Parameter(Mandatory = $true)] [System.String] $Path,
        ## Chocolatey package name, i.e. VirtualEngine.Build
        [Parameter(Mandatory = $true)] [System.String] $PackageName,
        ## Zip download Uri
        [Parameter(Mandatory = $true)] [System.String] $Uri
    )
    begin {
        if (Test-Path -Path $Path -PathType Leaf) {
            Write-Error ('Path "{0}" is not a directory.' -f $Path);
        }
        if ($Path -notmatch '\\tools\\?') {
            Write-Warning ('Path "{0}" does not include the \tools directory. Chocolatey install files should be placed in the \tools directory.' -f $Path);
        }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyModuleZipInstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyModuleZipUninstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    }
}
