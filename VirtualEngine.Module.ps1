#region Public Functions

function Get-ModuleManifest {
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
        .NOTES
            The Test-ModuleManifest does not support literal paths.
    #>
    [CmdletBinding()]
    [OutputType([PSModuleInfo])]
    param (
        # One or more file paths to search for a module manifest file.
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String[]] $Path = (Get-Location -PSProvider FileSystem)
    )
    begin {
        for ($i = 0; $i -lt $Path.Length; $i++) { 
            $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
    } #end begin
    process {
        foreach ($resolvedPath in $Path) {
            ## Do we have a file?        
            if (Test-Path -Path $resolvedPath -PathType Leaf) {
                ## Looks like it so assume this is a file..
                $ManifestPath = $resolvedPath;
            }
            else {
                ## We have a directory so attempt to resolve the manifest
                ## file as it should be the same as the directory name..
                $pathInfo = Get-Item -Path $resolvedPath;
                $ManifestPath = Join-Path -Path $pathInfo.FullName -ChildPath "$($pathInfo.Name).psd1";
                if (-not (Test-Path -Path $ManifestPath -PathType Leaf)) {
                    ## Hmmm - let's see if there's a .psd1 in the folder
                    $psd1Files = Get-ChildItem -Path $resolvedPath -Filter '*.psd1';
                    if ($psd1Files -eq $null) {
                        Write-Error ('No manifest file matching "{0}" found.' -f $ManifestPath);
                    }
                    elseif ($psd1Files.Count -gt 1) {
                        Write-Error ('Mulitple manifest files found in "{0}" found.' -f $Path);
                    }
                    else {
                        ## Use the discovered, single .psd1 file
                        $ManifestPath = $psd1Files.FullName;
                    }
                } #end if
            } #end if
            $moduleManifest = Test-ModuleManifest -Path $ManifestPath;
            Write-Output $moduleManifest;
        } #end foreach resolvedPath
    } #end process
} #end function Get-ModuleManifest

function Get-ModuleManifestProperty {
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
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param(
        # One or more file paths
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String[]] $Path = (Get-Location -PSProvider FileSystem),
        # One or literal file paths
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath,
        # Module manifest property to retrieve.
        [Parameter(Position=1, Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Module manifest property to return.')]
        [ValidateSet('Author','ClrVersion','CompanyName','Copyright','Definition','Description','DotNetFrameworkVersion','ExportedAliases',
        'ExportedCmdlets','ExportedCommands','ExportedFormatFiles','ExportedFunctions','ExportedTypeFiles','ExportedVariables',
        'ExportedWorkflows','FileList','Guid','HelpInfoUri','LogPipelineExectuionDetails','ModuleBase','ModuleList','ModuleType',
        'Name','NestedModules','OnRemove','Path','PowerShellHostName','PowerShellHostVersion','PowerShellVersion','Prefix',
        'PrivateData','ProcessorArchitecture','RequiredAssemblies','RootModule','Scripts','SessionState','Version')]
        [System.String] $Property,
        # Default value to return if the property is not found.
        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true, HelpMessage='Default value to return if the property is not found.')]
        [AllowNull()] [System.String] $Default = $null
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            $Path = $LiteralPath;
        } # end if
    } #end begin
    process {
        foreach ($resolvedPath in $Path) {
            ## Get the hashtable of module manifest key/value pairs
            $moduleManifest = Get-ModuleManifest -Path $Path;
            if ($moduleManifest.$Property -eq $null) {
                return $Default;
            }
            else {
                return $moduleManifest.$Property;
            }
        } #end foreach
    } #end process
} #end function Get-ModuleManifestProperty

function Get-ModuleFile {
    <#
    .SYNOPSIS
        Gets files to be bundled with a module release.
    .DESCRIPTION
        The Get-ModuleFile cmdlet gets a list of files to be included for a module
        release. It ignores the .Git folder and any file/folder specified in the .gitignore
        file if present.

        An additional array of files to be excluded can be passed in using the
        -Exclude parameter that performs pattern matching.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        # One or more file paths to enumerate.
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String] $Path = (Get-Location -PSProvider FileSystem),
        # One or more literal files paths to enumerate.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath,
        # File paths/matches to exclude.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyCollection()] [System.String[]] $Exclude = @()
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            $Path = $LiteralPath;
        } # end if
        if (-not (Test-Path -Path $Path -PathType Container)) {
            throw ('Not a valid directory path "{0}".' -f $Path);
        }
    } #end begin
    process {
        $moduleFiles = Get-ChildItem -Path $Path -Exclude '.git';
        $ignoredFiles = GetModuleExcludedFile -Path $Path;
        foreach ($moduleFile in $moduleFiles) {
            Write-Verbose ('Checking for excluded file "{0}".' -f $moduleFile.FullName);
            ## Check whether the file has been manually excluded
            $isExcluded = $false;
            foreach ($excludedFile in $Exclude) {
                if ($moduleFile.FullName -like $excludedFile -or $moduleFile.Name -like $excludedFile) {
                    $isExcluded = $true;
                    Write-Verbose ('File/directory "{0}" has been manually excluded.' -f $moduleFile);
                }
            }
            if ((-not $isExcluded) -and ($ignoredFiles.FullName -NotContains $moduleFile.FullName)) {
                Write-Output $moduleFile;
            }
        } # end foreach
    } #end process
} #end function Get-ModuleFile

function Set-ScriptSignature {
    <#
        .SYNOPSIS
            Signs a script file.
        .DESCRIPTION
            The Set-ScriptSignature cmdlet signs a PowerShell script file using the specified certificate thumbprint.
        .EXAMPLE
            Set-ScriptSignature -Path .\Example.psm1 -Thumbprint D10BB31E5CE3048A7D4DA0A4DD681F05A85504D3

            This example signs the 'Example.psm1' file in the current path using the certificate.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.Management.Automation.Signature])]
    param (
        # One or more files/paths of the files to sign.
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String[]] $Path = (Get-Location -PSProvider FileSystem),
        # One or more literal files/paths of the files to sign.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath,
        # Thumbprint of the certificate to use.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] [System.String] $Thumbprint,
        # Signing timestamp server URI
        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] [System.String] $TimeStampServer = 'http://timestamp.verisign.com/scripts/timestamp.dll'
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            for ($i = 0; $i -lt $Path.Length; $i++) { 
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        }
        else {
            $Path = $LiteralPath;
        } # end if
        $codeSigningCert = Get-ChildItem -Path Cert:\ -CodeSigningCert -Recurse | Where Thumbprint -eq $Thumbprint;
        if (!$codeSigningCert) {
            throw ('Invalid certificate thumbprint "{0}".' -f $Thumbprint);
        }
    } # end begin
    process {
        foreach ($resolvedPath in $Path) {
            if (Test-Path -Path $resolvedPath -PathType Leaf) {
                $scriptFile = Get-Item -Path $Path;
                #Push-Location $scriptFile.Directory;
                $signResult = Set-AuthenticodeSignature -Certificate $codeSigningCert -TimestampServer $TimeStampServer -FilePath $Path;
                if ($signResult.Status -ne 'Valid') {
                    Write-Error ('Error signing file "{0}".' -f $Path);
                }
                #Pop-Location;
                Write-Output $signResult;
            }
            else {
                Write-Warning ('File path "{0}" was not found or was a directory.' -f $resolvedPath);
            }
        } # end foreach
    } # end process
} #end function Set-ScriptSignature

function New-ModuleLicense {
    <#
        .SYNOPSIS
            Creates a new license file.
        .DESCRIPTION
            Creates a new Apache, GPLv2 or GPLv3 or by default, a MIT license file.
        .NOTES
            The -Project parameter is only applicable to the GPLv2 and GPLv3 licenses.
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
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        # File path to the license file to create.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath')] [System.String] $Path,
        # Literal file path to the license file to create.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String] $LiteralPath,
        # License type.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Apache','MIT','GPLv2','GPLv3')] [System.String] $LicenseType = 'MIT',
        # Licensee full name.
        [Parameter(Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()] [System.String] $FullName,
        # Project/product name.
        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()] [System.String] $Project = '',
        # Do not overwrite an existing file.
        [Parameter()] [Switch] $NoClobber
    )
    begin {
        
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $LiteralPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        if (Test-Path -LiteralPath $LiteralPath -PathType Container) {
            throw ('Invalid file path "{0}".' -f $LiteralPath);
        }
    } # end begin
    process {
        $license = $licenses[$LicenseType];
        $license = $license -replace '{year}', (Get-Date).Year;
        $license = $license -replace '{fullname}', $FullName;
        $license = $license -replace '{project}', $Project;
        if ($NoClobber -and (Test-Path -LiteralPath $LiteralPath)) {
            Write-Error ('File path "{0}" already exists.' -f $LiteralPath);
        }
        else {
            Set-Content -LiteralPath $LiteralPath -Value $license -Encoding Ascii -Force;
            Write-Output (Get-Item -LiteralPath $LiteralPath);
        }
    } # end process
} #end function New-ModuleLicense

#endregion Public Functions

#region Private Functions

function GetModuleExcludedFile {
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
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        # One or more file paths to enumerate.
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String] $Path = (Get-Location -PSProvider FileSystem),
        # One or more literal file paths to enumerate.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            $Path = $LiteralPath;
        } # end if
        if (-not (Test-Path -Path $Path -PathType Container)) {
            Write-Error ('Not a valid directory path "{0}".' -f $Path);
        }
        $gitAttributesPath = Join-Path -Path $Path -ChildPath '.gitattributes';
        if (-not (Test-Path -Path $gitAttributesPath -PathType Leaf)) {
            Write-Error ('No valid .gitattributes found in path "{0}".' -f $Path);
        }
        $gitIgnorePath = Join-Path -Path $Path -ChildPath '.gitignore';
        if (-not (Test-Path -Path $gitIgnorePath -PathType Leaf)) {
            Write-Error ('No valid .gitignore found in path "{0}".' -f $Path);
        }
    } #end begin
    process {
        ## Parse .gitignore
        if (-not ([System.String]::IsNullOrEmpty($gitIgnorePath))) {
            $gitIgnores = Get-Content -Path $gitIgnorePath -Force;
            foreach ($gitIgnore in $gitIgnores) {
                ## Check whether we have a directory
                if ($gitIgnore.Contains('/')) {
                    if (-not ($gitIgnore.StartsWith('/'))) {
                        ## Test path requires a leading \
                        $gitIgnore = "\{0}" -f $gitIgnore;
                    }
                    $gitIgnore = $gitIgnore.TrimEnd('/').Replace('/','\');
                } #end if directory
                $gitIgnore = $gitIgnore.Trim();
                $gitIgnorePath = Join-Path -Path $Path -ChildPath $gitIgnore;
                if (Test-Path -Path $gitIgnorePath) {
                    Write-Output (Get-Item -Path (Join-Path -Path $Path -ChildPath $gitIgnore));
                }
            } #end foreach gitIgnore
        } #end if

        ## Parse .gitattributes
        if (-not ([System.String]::IsNullOrEmpty($gitAttributesPath))) {
            $gitAttributes = Get-Content -Path $gitAttributesPath -Force;
            $gitAttributes = $gitAttributes | Select-String -SimpleMatch 'export-ignore';
            foreach ($gitAttribute in $gitAttributes) {
                $gitAttribute = $gitAttribute -replace 'export-ignore', '';
                $gitAttribute = $gitAttribute -replace '/', '\';
                $gitAttribute = $gitAttribute.Trim();
                $gitAttributePath = Join-Path -Path $Path -ChildPath $gitAttribute;
                if (Test-Path -Path $gitAttributePath) {
                    Write-Output (Get-Item -Path (Join-Path -Path $Path -ChildPath $gitAttribute));
                }
            } #end foreach
        } #end if
    } #end process
} #end function GetModuleExcludedFile

#endregion Private Functions

## Export public functions
#Export-ModuleMember -Function *-*;
