function Invoke-NuGetPack {
    <#
        .SYNOPSIS
            Packages the specified NuGet .nuspec package.
        .NOTES
            https://github.com/chocolatey/chocolatey/blob/master/src/functions/Chocolatey-Pack.ps1
    #>
    [CmdletBinding()]
    param (
        # File path to the NuGet .nuspec source file to pack.
        [Parameter(Mandatory = $true)] [System.String] $Path,
        # Output directory path for the NuGet package.
        [Parameter(Mandatory = $true)] [System.String] $DestinationPath
    )
    process {
        $nugetDirectoryPath = Split-Path $virtualEngineBuildNugetPath -Parent;
        $nuspecFilename = Get-Item -Path $Path;
        $packageArgs = 'pack "{0}" -NoPackageAnalysis -NonInteractive -OutputDirectory "{1}"' -f $Path, $DestinationPath;
        $logFile = Join-Path -Path $nugetDirectoryPath -ChildPath 'pack.log';
        $errorLogFile = Join-Path -Path $nugetDirectoryPath -ChildPath 'error.log';

        Write-Verbose ('Calling ''{0} {1}''.' -f $virtualEngineBuildNugetPath, $packageArgs);
        $process = Start-Process $virtualEngineBuildNugetPath -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile -PassThru;
        # this is here for specific cases in Posh v3 where -Wait is not honored
        try { if (!($process.HasExited)) { Wait-Process -Id $process.Id } } catch { }

        Get-Content -Path $logFile -Encoding Ascii;
        $errors = Get-Content $errorLogFile
        if ($process.ExitCode -ne 0) {
            Write-Error $errors;
        }
    } #end process
} #end function Invoke-NuGetPack

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
     [OutputType([System.Xml.XmlDocument])]
     param (
         # Powershell module information.
         [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName='Manifest')]
         [ValidateNotNull()] [System.Management.Automation.PSModuleInfo] $InputObject,
         # Unique identifier for the Nuget package.
         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [Alias('Id')] [System.String] $Name,
         # Package version, in a format like 1.2.3.
         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [System.String] $Version,
         # Human-friendly title of the package displayed. If none is specified, the Name is used instead.
         [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [System.String] $Title = $Name,
         # A list of authors of the package code.
         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [System.String[]] $Authors,
         # A list of the package creators.
         [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [AllowNull()] [System.String[]] $Owners,
         # A short description of the package.
         [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [AllowNull()] [System.String] $Summary,
         # A long description of the package.
         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [System.String] $Description,
         # A URL for the homepage of the package.
         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [System.String] $ProjectUrl,
         # A URL for the image to use as the icon for the package. This should be 32x32-pixel .png file.
         [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [AllowNull()] [System.String] $IconUrl,
         # A URL to the license that the package is under.
         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [System.String] $LicenseUrl,
         # Copyright details of the package.
         [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [ValidateNotNullOrEmpty()] [System.String] $Copyright,
         # Specifies whether the client needs to ensure that the package license is accepted before package installation.
         [Parameter(ValueFromPipelineByPropertyName=$true)]
         [Switch] $RequireLicenseAcceptance,
         # A list of tags and keywords that describe the package
         [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [AllowNull()] [System.String[]] $Tags,
         # A list of dependencies for the package.
         [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Manual')]
         [AllowNull()] [System.String[]] $Dependencies
     )
     process {
        if ($PSCmdlet.ParameterSetName -eq 'Manifest') {
            if (-not ($InputObject.ProjectUri)) {
                Write-Error ('Project Uri not specified in the module manifest.');
                break;
            }
            if (-not ($InputObject.LicenseUri)) {
                Write-Error ('License Uri not specified in the module manifest.');
                break;
            }
            $Name = $InputObject.Name;
            $Version = $InputObject.Version.ToString();
            $Title = $InputObject.Name;
            $Authors = @($InputObject.Author);
            $Owners = @($InputObject.CompanyName);
            $Description = $InputObject.Description;
            $ProjectUrl = $InputObject.ProjectUri.AbsoluteUri;
            $Copyright = $InputObject.Copyright;
            $LicenseUrl = $InputObject.LicenseUri.AbsoluteUri;
            $Tags = $InputObject.PrivateData.PSData.Tags;
            $IconUrl = $InputObject.IconUri.AbsoluteUri;
        }
        ## Ensure Id is lowercase and contains no spaces
        $Name = $Name.ToLower().Replace(' ','');

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
