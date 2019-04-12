[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments','')]
param ( )

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
    $installChocolateyZipPackageParams = @{
        PackageName   = '{packagename}';
        Url           = '{downloaduri}';
        UnzipLocation = "$scriptInstallPath";
        Checkum       = '{checksum}';
        CheckumType   = '{checksumtype}';
    }
    Install-ChocolateyZipPackage @installChocolateyZipPackageParams;
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
    $installChocolateyZipPackageParams = @{
        PackageName   = '{packagename}';
        Url           = '{downloaduri}';
        UnzipLocation = "$moduleInstallPath";
        Checkum       = '{checksum}';
        CheckumType   = '{checksumtype}';
    }
    Install-ChocolateyZipPackage @installChocolateyZipPackageParams;
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
$installChocolateyPackageParams = @{
    PackageName    = '{packagename}';
    FileType       = '{installertype}';
    SilentArgs     = '{arguments}';
    Url            = '{downloaduri}';
    ValidExitCodes = @({exitcodes});
    Checksum       = '{checksum}';
    ChecksumType   = '{checksumtype}';
}
Install-ChocolateyPackage @installChocolateyPackageParams;
'@;

$chocolateyUninstallExe = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for EXE installations
Uninstall-ChocolateyPackage -PackageName '{packagename}' -FileType 'EXE' -SilentArgs '{arguments}' -File "{uninstallfile}" -ValidExitCodes @({exitcodes});
'@;

$chocolateyUninstallMsi = @'
## Template VirtualEngine.Build ChocolateyUninstall.ps1 file for MSI installations
try {
    Get-WmiObject -Class Win32_Product | Where { $_.Name -eq '{productname}' } | ForEach-Object {
	    Uninstall-ChocolateyPackage -PackageName '{packagename}' -FileType 'MSI' -SilentArgs "$($_.IdentifyingNumber) /qn /norestart" -ValidExitCodes @({exitcodes});
    }
}
catch {
    throw $_.Exception;
}
'@;

$chocolateyInstallZipPackage = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for zipped EXE/MSI installations
$packageToolsPath = Split-Path -parent $MyInvocation.MyCommand.Definition;
$installChocolateyZipPackageParams = @{
    PackageName   = '{packagename}';
    Url           = '{downloaduri}'
    UnzipLocation = "$packageToolsPath";
}
Install-ChocolateyZipPackage @installChocolateyZipPackageParams;
$packageFilePath = Join-Path $packageToolsPath -ChildPath '{file}';
$installChocolateyInstallPackageParams = @{
    PackageName    = '{packagename}';
    FileType       = '{installertype}'
    SilentArgs     = '{arguments}';
    File           = "$packageFilePath";
    ValidExitCodes = @({exitcodes});
    Checkum        = '{checksum}';
    CheckumType    = '{checksumtype}';
}
Install-ChocolateyInstallPackage
'@;

$chocolateyInstallBundlePackage = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for bundled EXE/MSI installations
$packageToolsPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent;
$packagePath = Split-Path -Path $packageToolsPath -Parent;
$bundleFilePath = Join-Path -Path $packagePath -ChildPath '{file}';
Install-ChocolateyInstallPackage -PackageName '{packagename}' -FileType '{installertype}' -SilentArgs '{arguments}' -File $bundleFilePath -ValidExitCodes @({exitcodes});
'@;

$chocolateyInstallZipPortable = @'
## Template VirtualEngine.Build ChocolateyInstall.ps1 file for Zip-based portable installations
try {
    $packageToolsPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent;
    $packageRootPath = Split-Path -Path $packageToolsPath -Parent;
    $packageContentPath = Join-Path -Path $packageRootPath -ChildPath 'Content';
    [ref] $null = New-Item -Path $packageContentPath -ItemType Directory;
    foreach ($exe in (@({shim}))) {
        $exePath = Join-Path -Path $packageContentPath -ChildPath "$exe.gui";
        [Ref] $null = New-Item -Path $exePath -ItemType File -Force;
    }
    $installChocolateyZipPackageParams = @{
        PackageName   = '{packagename}';
        Url           = '{downloaduri}'
        UnzipLocation = "$packageContentPath";
        Checkum       = '{checksum}';
        CheckumType   = '{checksumtype}';
    }
    Install-ChocolateyZipPackage @installChocolateyZipPackageParams;
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
