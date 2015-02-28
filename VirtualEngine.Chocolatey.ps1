function TestChocolateyInstallPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [System.String] $Path
    )
    process {
        if (Test-Path -Path $Path -PathType Leaf) {
            Write-Error ('Path "{0}" is not a directory.' -f $Path);
            Write-Output $false;
        }
        if ($Path -notmatch '\\tools\\?') {
            Write-Warning ('Path "{0}" does not include the \tools directory. Chocolatey install files should be placed into this directory.' -f $Path);
        }
        Write-Output $true;
    }
}

$chocolateyModuleZipInstall = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based Powershell module installations
try {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:chocolateyPackageParameters -like '*AllUsers*') {
        $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
    }
    Write-Host ('Installing to "{0}".' -f $moduleInstallPath);
    Install-ChocolateyZipPackage '{packagename}' '{downloaduri}' "$moduleInstallPath";
}
catch {
    throw $_.Exception;
}
'@;

$chocolateyModuleZipUninstall = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Zip-based Powershell module installations
try {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:PackageParameters -like '*AllUsers') {
        $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
    }
    Write-Host ('Removing "{0}\{1}".' -f $moduleInstallPath, '{packagename}');
    Remove-Item -Path "$moduleInstallPath\{packagename}" -Recurse -Force;
}
catch {
    throw $_.Exception;
}
'@;

function New-ChocolateyInstallModule {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file for Powershell module installation.
        .DESCRIPTION
            This cmdlet copies ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files to the destination
            path specified for a zipped Powershell module installation.
            
            These files permit installation of the Powershell module into the (by default)
            user's WindowsPowershell\Modules path, or the machine C:\Program Files\WindowsPowershell
            \Module directory with the '-params allusers' installation parameter.
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
        if (-not (TestChocolateInstallPath -Path $Path)) { break; }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyModuleZipInstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyModuleZipUninstall -replace '\{packagename\}' |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function New-ChocolateyInstallModule

$chocolateyInstall = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for EXE/MSI installations
Install-ChocolateyPackage -PackageName '{packagename}' -FileType '{installertype}' -SilentArgs '{arguments}' -Url '{downloaduri}';
'@;

$chocolateyUninstallExe = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for EXE/MSI installations
Uninstall-ChocolateyPackage -PackageName '{packagename}' -FileType '{installertype}' -SilentArgs '{arguments}' -File "{uninstallfile}"; 
'@;

$chocolateyUninstallMsi = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for EXE/MSI installations
Uninstall-ChocolateyPackage -PackageName '{packagename}' -FileType '{installertype}' -SilentArgs '{arguments}'; 
'@;

function New-ChocolateyInstallPackage {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file MSI or EXE installation.
        .DESCRIPTION
            This cmdlet copies ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files to the destination
            path specified for MSI or unattended executable installation.
        .NOTES
            For MSI deployments, the uninstallation parameters need to be specified that prepent the
            /X parameter, for example '{ba79f56e-66e1-4ff6-bef5-98d22869dbd3} /qn /norestart'.

            For EXE deployments, the uninstallation file path must point to a locally installed file
            that performs the unattended installation.
    #>
    [CmdletBinding()]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Path,
        ## Chocolatey package name, i.e. VirtualEngine.Build
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $PackageName,
        ## Package URL download link.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Uri,
        ## Installer silent installation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Arguments,
        ## Installer silent uninstallation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $UninstallArguments,
        ## Installer is an EXE file.
        [Parameter(ParameterSetName = 'EXE')] [Switch] $EXE,
        ## File path to the native EXE uninstaller.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')] [System.String] $UninstallPath
    )
    begin {
        if (-not (TestChocolateInstallPath -Path $Path)) { break; }
        if ($PSCmdlet.ParameterSetName -eq 'EXE') { $fileType = 'EXE'; } else { $fileType = 'MSI'; }
        Write-Verbose ('Using parameter set name "{0}".' -f $PSCmdlet.ParameterSetName);
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri -replace '\{installertype\}', $fileType -replace '\{arguments\}', $Arguments |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        if ($PSCmdlet.ParameterSetName -eq 'EXE') {
            $chocolateyUninstallExe -replace '\{packagename\}', $PackageName -replace '\{installertype\}', $fileType -replace '\{arguments\}', $UninstallArguments -replace '\{uninstallfile\}', $UninstallPath |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
        else {
            $chocolateyUninstallMsi -replace '\{packagename\}', $PackageName -replace '\{installertype\}', $fileType -replace '\{arguments\}', $UninstallArguments |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
     } #end process
} #end function New-ChocolateyInstallPackage

$chocolateyPortableInstall = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based Powershell module installations
try {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:chocolateyPackageParameters -like '*AllUsers*') {
        $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
    }
    Write-Host ('Installing to "{0}".' -f $moduleInstallPath);
    Install-ChocolateyZipPackage '{packagename}' '{downloaduri}' "$moduleInstallPath";
}
catch {
    throw $_.Exception;
};
'@;

$chocolateyPortableUninstall = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Zip-based Powershell module installations
try {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:PackageParameters -like '*AllUsers') {
        $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
    }
    Write-Host ('Removing "{0}\{1}".' -f $moduleInstallPath, '{packagename}');
    Remove-Item -Path "$moduleInstallPath\{packagename}" -Recurse -Force;
}
catch {
    throw $_.Exception;
}
'@;

function New-ChocolateyInstallPortable {
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
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyPortableInstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyPortableUninstall -replace '\{packagename\}' |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function New-ChocolateyInstallPortable

$chocolateyScriptInstall = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Powershell script deployments
try {
    $scriptInstallPath = '{0}\WindowsPowershell' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:chocolateyPackageParameters -like '*AllUsers*') {
        $scriptInstallPath = '{0}\WindowsPowershell' -f $env:ProgramFiles;
    }
    $packagePath = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Parent;
    Write-Host ('Deploying script file(s) to ''{0}''.' -f $scriptInstallPath);
    Get-ChildItem -Path $packagePath -Exclude '{exclude}' | Copy-Item -Destination $scriptInstallPath;
}
catch {
    throw $_.Exception;
}
'@;
$chocolateyScriptUninstall = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Powershell script deployments
Write-Host 'Uninstallation of Powershell scripts is not supported - in case of script modifications.';
'@;

function New-ChocolateyInstallScript {
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
    [CmdletBinding()]
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
        $chocolateyScriptInstall -replace '\{exclude\}', [System.String]::Join("','", $Exclude) |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyScriptUninstall |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end functoin New-ChocolateyInstallScript
