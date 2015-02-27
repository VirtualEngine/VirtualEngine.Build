$chocolateyModuleZipInstall = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based installations

if ($env:chocolateyInstallArguments -like '*Scope*' -and $env:chocolateyInstallArguments -like '*AllUsers') {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
}
else {
    foreach ($modulePath in $env:PSModulePath.Split(';')) {
        if ($modulePath -inotlike '*\Program Files\*' -and $modulePath -inotlike '*\Windows\*') {
            $moduleInstallPath = $modulePath;
            break;
        }
    }
}

Install-ChocolateyZipPackage '{packagename}' '{downloaduri}' "$moduleInstallPath\{packagename}";
'@;

$chocolateyModuleZipUninstall = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Zip-based installations

if ($env:chocolateyInstallArguments -like '*Scope*' -and $env:chocolateyInstallArguments -like '*AllUsers') {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
}
else {
    foreach ($modulePath in $env:PSModulePath.Split(';')) {
        if ($modulePath -inotlike '*\Program Files\*' -and $modulePath -inotlike '*\Windows\*') {
            $moduleInstallPath = $modulePath;
            break;
        }
    }
}

Remove-Item -Path "$moduleInstallPath\{packagename}" -Recurse -Force;
'@;

function New-ChocolateyModuleInstall {
    <#
        .SYNOPSIS
            Creates a new Chocolatey Zip package for Powershell modules.
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
        if (Test-Path -Path $Path -PathType Container) {
            Write-Error ('Path "{0}" is not a directory.' -f $Path);
        }
        if ($Path -notmatch '\\tools\\?') {
            Write-Warning ('Path "{0}" does not include the \tools directory. Chocolatey install files should be placed in the \tools directory.' -f $Path);
        }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyModuleZipInstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$DestinationPath\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyModuleZipUninstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$DestinationPath\ChocolateyUninstall.ps1" -Encoding UTF8;
    }
}
