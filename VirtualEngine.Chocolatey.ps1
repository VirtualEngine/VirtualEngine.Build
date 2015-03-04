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

#region Templates

$chocolateyInstallVsix = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Visual Studio VSIX deployment
Install-ChocolateyVsixPackage -PackageName '{packagename}' -Url '{downloaduri}';
'@;

$chocolateyInstallZipScript = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based Powershell script deployment
try {
    $scriptInstallPath = '{0}\WindowsPowershell' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:chocolateyPackageParameters -like '*AllUsers*') {
        $scriptInstallPath = '{0}\WindowsPowershell' -f $env:ProgramFiles;
    }
    Install-ChocolateyZipPackage '{packagename}' '{downloaduri}' "$scriptInstallPath";
}
catch {
    throw $_.Exception;
}
'@;

$chocolateyUninstallZipScript = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Zip-based Powershell script deployment
Write-Host 'Uninstallation of Powershell scripts is not supported - in case of script modifications.';
'@;

$chocolateyInstallZipModule = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based Powershell module installations
try {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:chocolateyPackageParameters -like '*AllUsers*') {
        $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
    }
    Install-ChocolateyZipPackage '{packagename}' '{downloaduri}' "$moduleInstallPath";
}
catch {
    throw $_.Exception;
}
'@;

$chocolateyUninstallZipModule = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Zip-based Powershell module installations
try {
    $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f [System.Environment]::GetFolderPath('Personal');
    if ($env:PackageParameters -like '*AllUsers') {
        $moduleInstallPath = '{0}\WindowsPowershell\Modules' -f $env:ProgramFiles;
    }
    Remove-Item -Path "$moduleInstallPath\{packagename}" -Recurse -Force;
}
catch {
    throw $_.Exception;
}
'@;

$chocolateyInstall = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for EXE/MSI installations
Install-ChocolateyPackage -PackageName '{packagename}' -FileType '{installertype}' -SilentArgs '{arguments}' -Url '{downloaduri}';
'@;

$chocolateyUninstallExe = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for EXE installations
Uninstall-ChocolateyPackage -PackageName '{packagename}' -FileType 'EXE' -SilentArgs '{arguments}' -File "{uninstallfile}"; 
'@;

$chocolateyUninstallMsi = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for MSI installations
try {
    Get-WmiObject -Class Win32_Product | Where { $_.Name -eq '{productname}' } | ForEach-Object {
	    Uninstall-ChocolateyPackage -PackageName '{packagename}' -FileType 'MSI' -SilentArgs "$($_.IdentifyingNumber) /qn /norestart"; 
    }
}
catch {
    throw $_.Exception;
}
'@;

$chocolateyInstallZipPackage = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for zipped EXE/MSI installations
$packageToolsPath = Split-Path -parent $MyInvocation.MyCommand.Definition;
Install-ChocolateyZipPackage -PackageName '{packagename}' -Url '{downloaduri}' -UnzipLocation $packageToolsPath;
$packageFilePath = Join-Path $packageToolsPath -ChildPath '{file}';
Install-ChocolateyInstallPackage -PackageName '{packagename}' -FileType '{installertype}' -SilentArgs '{arguments}' -File $packageFilePath;
'@;

$chocolateyInstallBundlePackage = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for bundled EXE/MSI installations
$packageToolsPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent;
$packagePath = Split-Path -Path $packageToolsPath -Parent;
$bundleFilePath = Join-Path -Path $packagePath -ChildPath '{file}';
Install-ChocolateyInstallPackage -PackageName '{packagename}' -FileType '{installertype}' -SilentArgs '{arguments}' -File $bundleFilePath;
'@;

$chocolateyInstallZipPortable = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based portable installations
try {
    $packageToolsPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent;
    $packageRootPath = Split-Path -Path $packageToolsPath -Parent;
    $packageContentPath = Join-Path -Path $packageRootPath -ChildPath 'Content';
    [Ref] $null = New-Item -Path $packageContentPath -ItemType Directory;
    foreach ($exe in (@({shim}))) {
        $exePath = Join-Path -Path $packageContentPath -ChildPath "$exe.gui";
        [Ref] $null = New-Item -Path $exePath -ItemType File -Force;
    }
    Install-ChocolateyZipPackage '{packagename}' '{downloaduri}' "$packageContentPath";
}
catch {
    throw $_.Exception;
};
'@;

$chocolateyInstallBundleScript = @'
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
$chocolateyUninstallBundleScript = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for Powershell script deployments
Write-Host 'Uninstallation of Powershell scripts is not supported - in case of script modifications.';
'@;

#endregion Templates

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
        $chocolateyInstallVsix -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
    } #end process
} #end function New-ChocolateyInstallModule

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
        $chocolateyInstallZipModule -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyUninstallZipModule -replace '\{packagename\}' |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function New-ChocolateyInstallModule

function New-ChocolateyInstallZipPackage {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file a zipped MSI or EXE installation.
        .DESCRIPTION
            This cmdlet copies ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files to the destination
            path specified for MSI or unattended executable installation.
        .NOTES
            For MSI deployments, the uninstallation parameters need to be specified that prepent the
            /X parameter, for example '{ba79f56e-66e1-4ff6-bef5-98d22869dbd3} /qn /norestart'.

            For EXE deployments, the uninstallation file path must point to a locally installed file
            that performs the unattended installation.
    #>
    [CmdletBinding(DefaultParameterSetName = 'MSI')]
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
        ## Zipped file within the download link file.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $File,
        ## Installer silent installation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Arguments,
        ## Windows Installer product name for uninstallation
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [System.String] $ProductName,
        ## Installer silent uninstallation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $UninstallArguments,
        ## Installer is an EXE file.
        [Parameter(ParameterSetName = 'EXE')] [Switch] $EXE,
        ## File path to the native EXE uninstaller.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')] [System.String] $UninstallPath
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
        if ($PSCmdlet.ParameterSetName -eq 'EXE') { $fileType = 'EXE'; } else { $fileType = 'MSI'; }
        Write-Verbose ('Using parameter set name "{0}".' -f $PSCmdlet.ParameterSetName);
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstallZipPackage -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri -replace '\{installertype\}', $fileType -replace '\{arguments\}', $Arguments -replace  '\{file\}', $File |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        if ($PSCmdlet.ParameterSetName -eq 'EXE') {
            $chocolateyUninstallExe -replace '\{packagename\}', $PackageName -replace '\{arguments\}', $UninstallArguments -replace '\{uninstallfile\}', $UninstallPath |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
        else {
            $chocolateyUninstallMsi -replace '\{packagename\}', $PackageName -replace '\{productname\}', $ProductName |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
     } #end process
} #end function New-ChocolateyInstallZipPackage

function New-ChocolateyInstallBundledPackage {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file a bundled MSI or EXE installation.
        .DESCRIPTION
            This cmdlet copies ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files to the destination
            path specified for MSI or unattended executable installation.
        .NOTES
            For MSI deployments, the uninstallation parameters need to be specified that prepent the
            /X parameter, for example '{ba79f56e-66e1-4ff6-bef5-98d22869dbd3} /qn /norestart'.

            For EXE deployments, the uninstallation file path must point to a locally installed file
            that performs the unattended installation.
    #>
    [CmdletBinding(DefaultParameterSetName = 'MSI')]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Path,
        ## Chocolatey package name, i.e. VirtualEngine.Build
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $PackageName,
        ## Bundled file within the package for installation.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $File,
        ## Installer silent installation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Arguments,
        ## Windows Installer product name for uninstallation
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [System.String] $ProductName,
        ## Installer silent uninstallation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $UninstallArguments,
        ## Installer is an EXE file.
        [Parameter(ParameterSetName = 'EXE')] [Switch] $EXE,
        ## File path to the native EXE uninstaller.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')] [System.String] $UninstallPath
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
        if ($PSCmdlet.ParameterSetName -eq 'EXE') { $fileType = 'EXE'; } else { $fileType = 'MSI'; }
        Write-Verbose ('Using parameter set name "{0}".' -f $PSCmdlet.ParameterSetName);
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstallBundlePackage -replace '\{packagename\}', $PackageName -replace '\{file\}', $File -replace '\{installertype\}', $fileType -replace '\{arguments\}', $Arguments |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        if ($PSCmdlet.ParameterSetName -eq 'EXE') {
            $chocolateyUninstallExe -replace '\{packagename\}', $PackageName -replace '\{arguments\}', $UninstallArguments -replace '\{uninstallfile\}', $UninstallPath |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
        else {
            $chocolateyUninstallMsi -replace '\{packagename\}', $PackageName -replace '\{productname\}', $ProductName |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
     } #end process
} #end New-ChocolateyInstallBundledPackage

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
    [CmdletBinding(DefaultParameterSetName = 'MSI')]
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
        ## Windows Installer product name for uninstallation
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [System.String] $ProductName,
        ## Installer silent uninstallation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $UninstallArguments,
        ## Installer is an EXE file.
        [Parameter(ParameterSetName = 'EXE')] [Switch] $EXE,
        ## File path to the native EXE uninstaller.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')] [System.String] $UninstallPath
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
        if ($PSCmdlet.ParameterSetName -eq 'EXE') { $fileType = 'EXE'; } else { $fileType = 'MSI'; }
        Write-Verbose ('Using parameter set name "{0}".' -f $PSCmdlet.ParameterSetName);
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri -replace '\{installertype\}', $fileType -replace '\{arguments\}', $Arguments |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        if ($PSCmdlet.ParameterSetName -eq 'EXE') {
            $chocolateyUninstallExe -replace '\{packagename\}', $PackageName -replace '\{arguments\}', $UninstallArguments -replace '\{uninstallfile\}', $UninstallPath |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
        else {
            $chocolateyUninstallMsi -replace '\{packagename\}', $PackageName -replace '\{productname\}', $ProductName |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
     } #end process
} #end function New-ChocolateyInstallPackage

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
    [CmdletBinding()]
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
} #end function New-ChocolateyInstallPortable

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
        $chocolateyInstallZipScript -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyUninstallZipScript -replace '\{packagename\}' |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function New-ChocolateyInstallModule

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
        $chocolateyInstallBundleScript -replace '\{exclude\}', [System.String]::Join("','", $Exclude) |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        $chocolateyUninstallBundleScript |
            Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
    } #end process
} #end function New-ChocolateyInstallScript
