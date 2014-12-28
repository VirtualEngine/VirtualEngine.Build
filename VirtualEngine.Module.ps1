#region Public Functions

<#
.SYNOPSIS
    Gets a PowerShell module's manifest.
.DESCRIPTION
    The Get-ModuleManifest cmdlet returns the properties of the specified PowerShell module's
    manifest.
.EXAMPLE
    Get-ModuleManifest -Path .\Module1

    This example returns information about the PowerShell module contained in the 'Module1' directory.
.EXAMPLE
    Get-ModuleManifest -Path .\Module1\Module.psd1

    This example returns information about the PowerShell module defined in the 'Module1\Module.psd1'
    manifest file. Use this option to return information from manifests not located in folders of the
    same name.
#>
function Get-ModuleManifest {
    [CmdletBinding(DefaultParameterSetName='Path')]
    [OutputType([PSModuleInfo])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [string[]] $Path = (Get-Location -PSProvider FileSystem),
        
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [string[]] $LiteralPath
    )

    Begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            ## Resolve each path
            for ($i = 0; $i -lt $Path.Length; $i++) { 
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        } else {
            ## Set $Path reference to the literal path(s)
            $Path = $LiteralPath;
        } # end if
    }

    Process {

        foreach ($resolvedPath in $Path) {
            ## Do we have a file?        
            if (Test-Path $resolvedPath -PathType Leaf) {
                ## Looks like it so assume this is a file..
                $ManifestPath = $resolvedPath;
            }
            else {
 
                ## We have a directory so attempt to resolve the manifest
                ## file as it should be the same as the directory name..
                $pathInfo = Get-Item $resolvedPath;
                $ManifestPath = Join-Path $pathInfo.FullName "$($pathInfo.Name).psd1";

                if (-not(Test-Path $ManifestPath -PathType Leaf)) {

                    ## Hmmm - let's see if there's a .psd1 in the folder
                    $psd1Files = Get-ChildItem -Path $resolvedPath -Filter '*.psd1';
                    if ($psd1Files -eq $null) {
                        Write-Error ("No manifest file matching '{0}' found.." -f $ManifestPath);
                    }
                    elseif ($psd1Files.Count -gt 1) {
                        Write-Error ("Mulitple manifest files found in '{0}' found.." -f $Path);
                    }
                    else {
                        ## Use the discovered, single .psd1 file
                        $ManifestPath = $psd1Files.FullName;
                    } #end if
                } #end if
            } #end if

            $moduleManifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction SilentlyContinue;
            if (-not($?)) { throw 'Invalid module manifest file.'; }
            Write-Output $moduleManifest;

        } #end foreach Path
    } #end process
}

<#
.SYNOPSIS
    Gets a module manifest's property.
.DESCRIPTION
    The Get-ModuleManifestProperty cmdlet gets a individual property from a PowerShell module's manifest (.psd1) file.
.PARAMETER Path
    The file path to the module's manifest (.psd1) file.
.EXAMPLE
    Get-ModuleManifestProperty -Path .\example.psd1 -Property 'ModuleName'
    
    This command gets the 'ModuleName' property value from the module manifest's .\example.psd1 file.
#>
function Get-ModuleManifestProperty {
   [CmdletBinding(DefaultParameterSetName='Path')]
   # [OutputType([System.String])]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String[]] $Path = (Get-Location -PSProvider FileSystem),
        
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath,

        [Parameter(Position=1, Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Module manifest property to return.')]
        [ValidateSet('Author','ClrVersion','CompanyName','Copyright','Definition','Description','DotNetFrameworkVersion','ExportedAliases',
        'ExportedCmdlets','ExportedCommands','ExportedFormatFiles','ExportedFunctions','ExportedTypeFiles','ExportedVariables',
        'ExportedWorkflows','FileList','Guid','HelpInfoUri','LogPipelineExectuionDetails','ModuleBase','ModuleList','ModuleType',
        'Name','NestedModules','OnRemove','Path','PowerShellHostName','PowerShellHostVersion','PowerShellVersion','Prefix',
        'PrivateData','ProcessorArchitecture','RequiredAssemblies','RootModule','Scripts','SessionState','Version')]
        [System.String] $Property,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true, HelpMessage='Default value to return if the property is not found.')]
        [AllowNull()] [System.String] $Default = $null
    )

    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            ## Resolve path
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            ## Set $Path reference to the literal path
            $Path = $LiteralPath;
        } # end if
    }

    process {
        
        foreach ($resolvedPath in $Path) {
            ## Get the hashtable of module manifest key/value pairs
            $moduleManifest = Get-ModuleManifest -Path $Path;

            if ($moduleManifest.$Property -eq $null) {
                ## Invalid or null property, so return the default value
                return $Default;
            }
            else {
                return $moduleManifest.$Property;
            }

        } #end foreach
    }
}

<#
.SYNOPSIS
    Gets files to be bundled with a module release.
.DESCRIPTION
    The Get-ModuleFiles cmdlets gets a list of files to be included for a module release.
#>
function Get-ModuleFile {
    [CmdletBinding(DefaultParameterSetName='Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String] $Path = (Get-Location -PSProvider FileSystem),
        
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyCollection()] [System.String[]] $Exclude = @()
    )

    begin {
        
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            ## Resolve path
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            ## Set $Path reference to the literal path
            $Path = $LiteralPath;
        } # end if

        ## Test we have a directory
        if (-not(Test-Path $Path -PathType Container)) {
            throw ("Not a valid directory path '{0}'." -f $Path);
        }

    } #end begin

    process {

        $moduleFiles = Get-ChildItem -Path $Path -Exclude '.git' -Recurse;
        $ignoredFiles = GetModuleExcludedFile -Path $Path;

        foreach ($moduleFile in $moduleFiles) {
            Write-Verbose ("Checking for excluded file '{0}'." -f $moduleFile.FullName);

            ## Check whether the file has been manually excluded
            $isExcluded = $false;
            foreach ($excludedFile in $Exclude) {
                if ($moduleFile.FullName -Like $excludedFile) {
                    $isExcluded = $true;
                    Write-Verbose ("File/directory '{0}' has been manually excluded." -f $moduleFile);
                }
            }
           
            if ((-not $isExcluded) -and ($ignoredFiles.FullName -NotContains $moduleFile.FullName)) {
                Write-Output $moduleFile;
            }
        } # end foreach
    } #end process
}

<#
.SYNOPSIS
    Signs a script file.
.DESCRIPTION
    The Set-ScriptSignature cmdlet signs a PowerShell script file using the specified certificate thumbprint.
.EXAMPLE
    Set-ScriptSignature -Path .\Example.psm1 -Thumbprint D10BB31E5CE3048A7D4DA0A4DD681F05A85504D3

    This example signs the 'Example.psm1' file in the current path using the certificate.
#>
function Set-ScriptSigntaure {
    [CmdletBinding(DefaultParameterSetName='Path')]
    [OutputType([System.Management.Automation.Signature])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [string[]] $Path = (Get-Location -PSProvider FileSystem),
        
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [string[]] $LiteralPath,
        
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] [string] $Thumbprint,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] [string] $TimeStampServer = "http://timestamp.verisign.com/scripts/timestamp.dll"
    )

    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            ## Resolve each path
            for ($i = 0; $i -lt $Path.Length; $i++) { 
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        }
        else {
            ## Set $Path reference to the literal path(s)
            $Path = $LiteralPath;
        } # end if

        $codeSigningCert = Get-ChildItem -Path Cert:\ -CodeSigningCert -Recurse | Where Thumbprint -eq $Thumbprint;
        if (!$codeSigningCert) {
            throw ("Invalid certificate thumbprint '{0}'." -f $Thumbprint);
        }

    } # end begin

    process {

        ## Process each resolved path
        foreach ($resolvedPath in $Path) {
            if (Test-Path $resolvedPath -PathType Leaf) {
                $scriptFile = Get-Item $Path;
                Push-Location $scriptFile.Directory;

                $signResult = Set-AuthenticodeSignature -Certificate $codeSigningCert -TimestampServer $TimeStampServer -FilePath $Path;

                $signResult | gm;
                if ($signResult.Status -ne 'Valid') {
                    Write-Warning ("Error signing file '{0}'." -f $Path);
                }

                Pop-Location;
                Write-Output $signResult;
            }
        } # end foreach
    } # end process
} #end function Set-ScriptSignature

<#
.SYNOPSIS
    Creates a new license file.
.DESCRIPTION
    Creates a new license file of either the GPLv2 or MIT license type.
.EXAMPLE
    New-ModuleLicense -Path .\LICENSE -FullName 'Virtual Engine Limited'

    Creates a new MIT 'LICENSE' file in the current directory stamped with the
    current year and licensed to 'Virtual Engine Limited'.

.EXAMPLE
    New-ModuleLicense -Path .\LICENSE.txt -FullName 'Virtual Engine Limited' -Project 'Virtual Engine Build' -LicenseType GPLv3

    Creates a new GPL v3 'LICENSE.txt' file in the current directory stamped with the
    current year, licensed to 'Virtual Engine Limited' with a project name of
    'Virtual Engine Build'.
#>
function New-ModuleLicense {
    [CmdletBinding(DefaultParameterSetName='Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath')] [string[]] $Path = (Get-Location -PSProvider FileSystem),

        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [string[]] $LiteralPath,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Apache','MIT','GPLv2','GPLv3')] [string] $LicenseType = 'MIT',

        [Parameter(Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] [string] $FullName,
        
        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()] [string] $Project = ''
    )

    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            ## Resolve each path
            for ($i = 0; $i -lt $Path.Length; $i++) { 
                if (-not(Test-Path $Path[$i] -PathType Container)) { throw ("Invalid directory path '{0}'." -f $Path[$i]); }
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        } else {
            ## Set $Path reference to the literal path(s)
            $Path = $LiteralPath;
        } # end if

    } # end begin

    process {

        ## Process each resolved path
        foreach ($resolvedPath in $Path) {
            
            $license = $Licenses[$LicenseType];
            $license = $license -replace '{year}', (Get-Date).Year;
            $license = $license -replace '{fullname}', $FullName;
            $license = $license -replace '{project}', $Project;

            Set-Content -Path $resolvedPath -Value $license -Encoding Ascii -Force;
        } # end foreach
    } # end process
} #end function New-ModuleLicense

#endregion Public Functions

#region Private Functions

<#
.SYNOPSIS
    Returns files to be excluded from a module release.
.DESCRIPTION
    The GetModuleExcludedFiles cmdlets returns all files that are excluded from a module
    release. Properties of the .gitignore and .gitattributes files are parsed to determine
    which files are not required in a release bundle.
.NOTES
    This is an internal module function that is not intended to be called directly.
#>
function GetModuleExcludedFile {
    [CmdletBinding(DefaultParameterSetName='Path')]
    [OutputType([System.IO.FileInfo])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [string] $Path = (Get-Location -PSProvider FileSystem),
        
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [string[]] $LiteralPath
    )

    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            ## Resolve path
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            ## Set $Path reference to the literal path
            $Path = $LiteralPath;
        } # end if

        ## Test we have a directory
        if (-not(Test-Path $Path -PathType Container)) {
            Write-Error ("Not a valid directory path '{0}'." -f $Path);
        }

        $gitAttributesPath = Join-Path -Path $Path -ChildPath '.gitattributes';
        if (-not(Test-Path $gitAttributesPath -PathType Leaf)) {
            Write-Error ("No valid .gitattributes found in path '{0}'." -f $Path);
        }

        $gitIgnorePath = Join-Path -Path $Path -ChildPath '.gitignore';
        if (-not(Test-Path $gitIgnorePath -PathType Leaf)) {
            Write-Error ("No valid .gitignore found in path '{0}'." -f $Path);
        }
    } #end begin

    process {
        
        ## Parse .gitignore
        if (-not([string]::IsNullOrEmpty($gitIgnorePath))) {
            $gitIgnores = Get-Content -Path $gitIgnorePath -Force;

            foreach ($gitIgnore in $gitIgnores) {
                
                ## Check whether we have a directory
                if ($gitIgnore.Contains('/')) {
                    if (-not ($gitIgnore.StartsWith('/'))) {
                        ## Test path requires a leading \
                        $gitIgnore = "\{0}" -f $gitIgnore;
                    }
                    $gitIgnore = $gitIgnore.TrimEnd('/').Replace('/','\');
                }

                $gitIgnore = $gitIgnore.Trim();
                $gitIgnorePath = Join-Path -Path $Path -ChildPath $gitIgnore;

                if (Test-Path -Path $gitIgnorePath) {
                    Write-Output (Get-Item -Path (Join-Path -Path $Path -ChildPath $gitIgnore));
                }
            } #end foreach gitIgnore
        } #end if

        ## Parse .gitattributes
        if (-not([string]::IsNullOrEmpty($gitAttributesPath))) {
            $gitAttributes = Get-Content -Path $gitAttributesPath -Force;
            $gitAttributes = $gitAttributes | Select-String -SimpleMatch "export-ignore";

            foreach ($gitAttribute in $gitAttributes) {
                $gitAttribute = $gitAttribute -replace 'export-ignore', '';
                $gitAttribute = $gitAttribute -replace '/', '\';
                $gitAttribute = $gitAttribute.Trim();
                $gitAttributePath = Join-Path $Path $gitAttribute;

                if (Test-Path -Path $gitAttributePath) {
                    Write-Output (Get-Item -Path (Join-Path $Path $gitAttribute));
                }
            } #end foreach
        } #end if
    } #end process
} #end function GetModuleExcludedFile

#endregion Private Functions

## Export public functions
Export-ModuleMember -Function *-*;
