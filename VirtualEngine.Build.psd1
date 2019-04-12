@{
    RootModule = 'VirtualEngine.Build.psm1';
    ModuleVersion = '1.0.0';
    GUID = '55b9490e-2766-45f8-bfc7-4e919943bfaa';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2019 Virtual Engine Limited. All rights reserved.';
    Description = 'The VirtualEngine.Build module contains build helper cmdlets that are used to bundle Powershell modules and Visual Studio binary releases.';
    PowerShellVersion = '3.0';
    FunctionsToExport = @(
                            'ConvertFrom-SecureString',
                            'Copy-GitRepository',
                            'Get-FileEncoding',
                            'Get-GitRevision',
                            'Get-GitRemoteOrigin',
                            'Get-GitVersionString',
                            'Get-ModuleFile',
                            'Get-ModuleManifest',
                            'Get-ModuleManifestProperty',
                            'Get-WindowsInstallerPackageProperty',
                            'Invoke-NuGetPack',
                            'Invoke-NuGetPush',
                            'New-ChocolateyInstallBundledPackage',
                            'New-ChocolateyInstallBundledScript',
                            'New-ChocolateyInstallPackage',
                            'New-ChocolateyInstallVsix',
                            'New-ChocolateyInstallZipModule',
                            'New-ChocolateyInstallZipPackage',
                            'New-ChocolateyInstallZipPortable',
                            'New-ChocolateyInstallZipScript',
                            'New-ModuleLicense',
                            'New-ModuleVersionNumber',
                            'New-NuGetNuspec',
                            'Read-Credential',
                            'Read-SecureString',
                            'Set-ModuleManifestProperty',
                            'Set-NuspecProperty',
                            'Set-ScriptSignature',
                            'Set-VSAssemblyInfo';
                            'Test-Git',
                            'Test-GitRemoteOrigin',
                            'Test-GitRepository',
                            'Update-GitRepository',
                            'Write-Credential',
                            'Write-SecureString'
                        ;)
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Powershell','Build','Helper');
            LicenseUri = 'https://github.com/VirtualEngine/VirtualEngine.Build/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/VirtualEngine.Build';
            IconUri = 'https://cdn.rawgit.com/VirtualEngine/Compression/38aa3a3c879fd6564d659d41bffe62ec91fb47ab/icon.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
