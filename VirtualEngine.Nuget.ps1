<#
.SYNOPSIS
    Create a new Nuget Specification document.
.DESCRIPTION
    The New-NugetSpec cmdlet creates a new Nuget .nuspec Xml document.
.EXAMPLE
    Get-ModuleManifest -Path .\VirtualEngine-Exmaple | New-NugetSpec -LicenseUrl 'http://gihub.com/virtualengine/example/LICENSE'
#>
function New-NuGetNuspec {
     [CmdletBinding(DefaultParameterSetName='Manifest', HelpUri = 'http://github.com/virtualengine/Build')]
     [OutputType([System.Xml.XmlDocument])]

     Param (
         # Powershell module information.
         [Parameter(Mandatory=$true, ValueFromPipeline=$true,ParameterSetName='Manifest')]
         [ValidateNotNull()] [System.Management.Automation.PSModuleInfo] $InputObject,
         # Unique identifier for the Nuget package.
         [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [string] $Id,
         # Package version, in a format like 1.2.3.
         [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [string] $Version,
         # Human-friendly title of the package displayed. If none is specified, the Id is used instead.
         [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [string] $Title = $Id,
         # A list of authors of the package code.
         [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [string[]] $Authors,
         # A list of the package creators.
         [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [AllowNull()] [string] $Owners,
         # A short description of the package.
         [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [AllowNull()] [string] $Summary,
         # A long description of the package.
         [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [string] $Description,
         # A URL for the homepage of the package.
         [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [string] $ProjectUrl,
         # A URL for the image to use as the icon for the package. This should be 32x32-pixel .png file.
         [Parameter(ValueFromPipelineByPropertyName=$true)]
         [AllowNull()] [string] $IconUrl,
         # A URL to the license that the package is under.
         [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
         [ValidateNotNullOrEmpty()] [string] $LicenseUrl,
         # Copyright details of the package.
         [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [string] $Copyright,
         # Specifies whether the client needs to ensure that the package license is accepted before package installation.
         [Parameter(ValueFromPipelineByPropertyName=$true)]
         [Switch] $RequireLicenseAcceptance,
         # A list of tags and keywords that describe the package
         [Parameter(ValueFromPipelineByPropertyName=$true)]
         [AllowNull()] [string[]] $Tags,
         # A list of dependencies for the package.
         [Parameter(ValueFromPipelineByPropertyName=$true)]
         [AllowNull()] [string[]] $Dependencies,
         # Add date stamp to version
         [Parameter(ValueFromPipelineByPropertyName=$true)]
         [Switch] $DateStampVersion
     )
 
     process {

        if ($PSCmdlet.ParameterSetName -eq 'Manifest') {
            $Id = $InputObject.Name.Replace('.','-');
            $Version = $InputObject.Version.ToString();
            $Title = $Id;
            $Authors = @($InputObject.Author);
            $Owners = $InputObject.CompanyName;
            $Description = $InputObject.Description;
            $ProjectUrl = $InputObject.HelpInfoUri;
            $Copyright = $InputObject.Copyright;
        }

        ## Create .nuspec
        [System.Xml.XmlDocument] $nuspec = New-Object System.Xml.XmlDocument;
        [ref] $null = $nuspec.AppendChild($nuspec.CreateXmlDeclaration('1.0', 'utf-8', 'yes'));
        $package = $nuspec.AppendChild($nuspec.CreateElement('package'));
        $package.SetAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
        $package.SetAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');

        $metadata = $package.AppendChild($nuspec.CreateElement('metadata'));

        $idNode = $metadata.AppendChild($nuspec.CreateElement('id'));
        [ref] $null = $idNode.AppendChild($nuspec.CreateTextNode($Id));

        $titleNode = $metadata.AppendChild($nuspec.CreateElement('title'));
        [ref] $null = $titleNode.AppendChild($nuspec.CreateTextNode($Title));

        $versionNode = $metadata.AppendChild($nuspec.CreateElement('version'));
        if ($DateStampVersion) {
            [ref] $null = $versionNode.AppendChild($nuspec.CreateTextNode("$Version.$((Get-Date).ToString('yyyyMMdd'))"));
        }
        else {
            [ref] $null = $versionNode.AppendChild($nuspec.CreateTextNode($Version));
        }

        $authorsNode = $metadata.AppendChild($nuspec.CreateElement('authors'));
        [ref] $null = $authorsNode.AppendChild($nuspec.CreateTextNode([string]::Join(',', $Authors)));

        $ownersNode = $metadata.AppendChild($nuspec.CreateElement('owners'));
        [ref] $null = $ownersNode.AppendChild($nuspec.CreateTextNode([string]::Join(',', $Owners)));

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

        $licenseUrlNode = $metadata.AppendChild($nuspec.CreateElement('licenseUrl'));
        [ref] $null = $licenseUrlNode.AppendChild($nuspec.CreateTextNode($LicenseUrl));

        $requireLicenseAcceptanceNode = $metadata.AppendChild($nuspec.CreateElement('requireLicenseAcceptance'));
        [ref] $null = $requireLicenseAcceptanceNode.AppendChild($nuspec.CreateTextNode($RequireLicenseAcceptance.ToString().ToLower()));

        if ($Tags) {
            $tagsNode = $metadata.AppendChild($nuspec.CreateElement('tags'));
            [ref] $null = $tagsNode.AppendChild($nuspec.CreateTextNode([string]::Join(' ', $Tags)));
        }

        Write-Output $nuspec;

     } #end process
} #end function New-NuGetNuspec
 