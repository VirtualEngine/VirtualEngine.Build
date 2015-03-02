@{

    RootModule = 'VirtualEngine.Build.psm1';
    ModuleVersion = '0.0.0.0';
    GUID = '55b9490e-2766-45f8-bfc7-4e919943bfaa';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine Limited';
    Copyright = '(c) Virtual Engine Limited. All rights reserved.';
    Description = 'The VirtualEngine.Build module contains cmdlets that are used to bundle Powershell module releases and Visual Studio binaries.';
    PowerShellVersion = '3.0';
    FunctionsToExport = '*-*';
    CmdletsToExport = '*-*';
    VariablesToExport = '*';
    AliasesToExport = '*';
    FileList = '';
    PrivateData = @{
        ## PSData is used by PowershellGet
        PSData = @{
            Tags = @('VirtualEngine','Build');
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/VirtualEngine/Build/blob/master/LICENSE';

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/VirtualEngine/Build'

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
