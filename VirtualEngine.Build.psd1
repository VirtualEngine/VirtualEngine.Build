@{

    RootModule = 'VirtualEngine.Build.psm1';
    ModuleVersion = '1.0.0';
    GUID = '55b9490e-2766-45f8-bfc7-4e919943bfaa';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) Virtual Engine Limited. All rights reserved.';
    Description = 'The VirtualEngine.Build module contains cmdlets that are used to bundle module releases.';
    PowerShellVersion = '3.0';
    RequiredModules = @('VirtualEngine.Compression');
    FunctionsToExport = '*-*';
    CmdletsToExport = '*-*';
    VariablesToExport = '*';
    AliasesToExport = '*';
    FileList = @('VirtualEngine.Build.psd1','VirtualEngine.Build.psm1','VirtualEngine.Module.ps1','VirtualEngine.Nuget.ps1');
    PrivateData = @{
        PSData = @{
            Tags = @('VirtualEngine','Build');
            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable
    } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

