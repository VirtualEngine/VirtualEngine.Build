function New-NuGetNuspec {
<#
    .SYNOPSIS
        Create a new Nuget Specification document.
    .DESCRIPTION
        The New-NugetSpec cmdlet creates a new Nuget .nuspec Xml document.
    .EXAMPLE
        Get-ModuleManifest -Path .\VirtualEngine-Exmaple | New-NugetSpec -LicenseUrl 'http://gihub.com/virtualengine/example/LICENSE'
#>
        [CmdletBinding(DefaultParameterSetName='Manifest', HelpUri = 'http://github.com/virtualengine/Build')]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
        [OutputType([System.Xml.XmlDocument])]
        param (
            # Powershell module information.
            [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='Manifest')]
            [ValidateNotNull()]
            [System.Management.Automation.PSModuleInfo] $InputObject,

            # Unique identifier for the Nuget package.
            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()] [Alias('Id')]
            [System.String] $Name,

            # Package version, in a format like 1.2.3.
            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String] $Version,

            # Human-friendly title of the package displayed. If none is specified, the Name is used instead.
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String] $Title = $Name,

            # A list of authors of the package code.
            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String[]] $Authors,

            # A list of the package creators.
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [AllowNull()]
            [System.String[]] $Owners,

            # A short description of the package.
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String] $Summary = $Title,

            # A long description of the package.
            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String] $Description,

            # A URL for the homepage of the package.
            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String] $ProjectUrl,

            # A URL for the image to use as the icon for the package. This should be 32x32-pixel .png file.
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [AllowNull()]
            [System.String] $IconUrl,

            # A URL to the license that the package is under.
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [AllowNull()]
            [System.String] $LicenseUrl,

            # Copyright details of the package.
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String] $Copyright,

            # Specifies whether the client needs to ensure that the package license is accepted before package installation.
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.Management.Automation.SwitchParameter] $RequireLicenseAcceptance,

            # A list of tags and keywords that describe the package
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [AllowNull()]
            [System.String[]] $Tags,

            # A list of dependencies for the package. Specify version number after the package name with a colon, i.e. VirtualEngine-Compression:1.1.0.18
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [AllowNull()]
            [System.String[]] $Dependencies,

            # Allows potential collaborators to easily find your package source so they can provide fixes
            # NOTE: Choco only
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String] $PackageSourceUrl,

            # Gives folks a way of knowing what has changed between versions of the software (and sometimes related to pacakging changes)
            # NOTE: Choco only
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Manual')]
            [ValidateNotNullOrEmpty()]
            [System.String[]] $ReleaseNotes
        )
        begin {

        if (-not ($Copyright) -and $Owners) {
            $Copyright = '(c) Copyright {0}' -f [System.String]::Join(',', $Owners);
        }

        }
        process {

        if ($PSCmdlet.ParameterSetName -eq 'Manifest') {
            if (-not ($InputObject.PrivateData.PSData.ProjectUri)) {
                Write-Error ($localized.ProjectUriNotDefinedError);
                break;
            }
            if ($InputObject.PrivateData.PSData.LicenseUri) {
                $LicenseUrl = $InputObject.PrivateData.PSData.LicenseUri;
            }
            $Name = $InputObject.Name;
            $Version = $InputObject.Version.ToString();
            $Title = $InputObject.Name;
            $Authors = @($InputObject.Author);
            $Owners = @($InputObject.CompanyName);
            $Description = $InputObject.Description;
            $Summary = $InputObject.Description;
            $ProjectUrl = $InputObject.PrivateData.PSData.ProjectUri;
            $Copyright = $InputObject.Copyright;
            $Tags = $InputObject.PrivateData.PSData.Tags;
            $IconUrl = $InputObject.PrivateData.PSData.IconUri;
        }
        ## Ensure Id is lowercase and contains no spaces
        $Name = $Name.ToLower().Replace(' ','-');

        ## Create .nuspec
        [System.Xml.XmlDocument] $nuspec = New-Object System.Xml.XmlDocument;
        [ref] $null = $nuspec.AppendChild($nuspec.CreateXmlDeclaration('1.0', 'utf-8', 'yes'));
        $package = $nuspec.AppendChild($nuspec.CreateElement('package'));
        $package.SetAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
        $package.SetAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
        $metadata = $package.AppendChild($nuspec.CreateElement('metadata'));
        $idNode = $metadata.AppendChild($nuspec.CreateElement('id'));
        [ref] $null = $idNode.AppendChild($nuspec.CreateTextNode($Name));
        $titleNode = $metadata.AppendChild($nuspec.CreateElement('title'));
        [ref] $null = $titleNode.AppendChild($nuspec.CreateTextNode($Title));
        $versionNode = $metadata.AppendChild($nuspec.CreateElement('version'));
        [ref] $null = $versionNode.AppendChild($nuspec.CreateTextNode($Version));
        $authorsNode = $metadata.AppendChild($nuspec.CreateElement('authors'));
        [ref] $null = $authorsNode.AppendChild($nuspec.CreateTextNode([string]::Join(',', $Authors)));
        $ownersNode = $metadata.AppendChild($nuspec.CreateElement('owners'));
        [ref] $null = $ownersNode.AppendChild($nuspec.CreateTextNode([string]::Join(',', $Owners)));
        $summaryNode = $metadata.AppendChild($nuspec.CreateElement('summary'));
        [ref] $null = $summaryNode.AppendChild($nuspec.CreateTextNode($Summary));
        $descriptionNode = $metadata.AppendChild($nuspec.CreateElement('description'));
        [ref] $null = $descriptionNode.AppendChild($nuspec.CreateTextNode($Description));
        $projectUrlNode = $metadata.AppendChild($nuspec.CreateElement('projectUrl'));
        [ref] $null = $projectUrlNode.AppendChild($nuspec.CreateTextNode($ProjectUrl));
        $copyrightNode = $metadata.AppendChild($nuspec.CreateElement('copyright'));
        [ref] $null = $copyrightNode.AppendChild($nuspec.CreateTextNode($Copyright));
        if ($IconUrl) {
            $iconUrlNode = $metadata.AppendChild($nuspec.CreateElement('iconUrl'));
            [ref] $null = $iconUrlNode.AppendChild($nuspec.CreateTextNode($IconUrl));
        }
        if ($LicenseUrl) {
            $licenseUrlNode = $metadata.AppendChild($nuspec.CreateElement('licenseUrl'));
            [ref] $null = $licenseUrlNode.AppendChild($nuspec.CreateTextNode($LicenseUrl));
            $requireLicenseAcceptanceNode = $metadata.AppendChild($nuspec.CreateElement('requireLicenseAcceptance'));
            [ref] $null = $requireLicenseAcceptanceNode.AppendChild($nuspec.CreateTextNode($RequireLicenseAcceptance.ToString().ToLower()));
        }
        if ($Tags) {
            $tagsNode = $metadata.AppendChild($nuspec.CreateElement('tags'));
            [ref] $null = $tagsNode.AppendChild($nuspec.CreateTextNode([string]::Join(' ', $Tags)));
        }
        if ($Dependencies) {
            $dependenciesNode = $metadata.AppendChild($nuspec.CreateElement('dependencies'));
            foreach ($dependency in $Dependencies) {
                $dependencyNode = $dependenciesNode.AppendChild($nuspec.CreateElement('dependency'));
                $dependencySplit = $dependency.Split(':');
                $dependencyNode.SetAttribute('id', $dependencySplit[0]);
                if ($dependencySplit[1]) { $dependencyNode.SetAttribute('version', $dependencySplit[1]); }
            }
        }
        if ($PackageSourceUrl) {
            $packageSourceUrlNode = $metadata.AppendChild($nuspec.CreateElement('packageSourceUrl'));
            [ref] $null = $packageSourceUrlNode.AppendChild($nuspec.CreateTextNode($PackageSourceUrl));
        }
        if ($ReleaseNotes) {
            $releaseNotesNode = $metadata.AppendChild($nuspec.CreateElement('releaseNotes'));
            [ref] $null = $releaseNotesNode.AppendChild($nuspec.CreateTextNode([string]::Join("`r`n", $ReleaseNotes)));
        }
        Write-Output $nuspec;

        } #end process
} #end function
