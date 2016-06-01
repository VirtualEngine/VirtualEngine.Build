@{
    RootModule = 'VirtualEngine.Build.psm1';
    ModuleVersion = '0.4.2.0';
    GUID = '55b9490e-2766-45f8-bfc7-4e919943bfaa';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description = 'The VirtualEngine.Build module contains cmdlets that are used to bundle Powershell module releases and Visual Studio binaries.';
    PowerShellVersion = '3.0';
    FunctionsToExport = '*-*';
    CmdletsToExport = '*-*';
    VariablesToExport = '*';
    AliasesToExport = '*';
    FileList = '';
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Powershell','Build');
            LicenseUri = 'https://github.com/VirtualEngine/Build/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/Build';
            IconUri = 'https://cdn.rawgit.com/VirtualEngine/Compression/38aa3a3c879fd6564d659d41bffe62ec91fb47ab/icon.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
