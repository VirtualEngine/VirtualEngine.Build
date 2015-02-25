$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe 'New-ModuleLicense' {
    . "$here\Licenses.ps1";
    $relativePath = '.\license.txt';
    $fullname = 'Iain Brighton';
    $projectName = 'VirtualEngine.Build';

    Context 'default MIT License' {

        $literalPath = "$((Get-PSDrive -Name TestDrive).Root)\[license].txt";

        It 'defaults to MIT license by relative path.' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname;
            { (Get-Content -Path $relativePath) -match $fullname } | Should Be $true;
            Pop-Location;
        }

        It 'defaults to MIT license by literal path.' {
            $license = New-ModuleLicense -LiteralPath $literalPath -FullName 'Iain Brighton';
            { (Get-Content -LiteralPath $license.FullName) -match 'The MIT License (MIT)' } | Should Be $true;
        }

        It 'sets default MIT license fullname' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname;
            { (Get-Content -Path $relativePath) -match $fullname } | Should Be $true;
            { (Get-Content -Path $relativePath) -notmatch '{fullname}' } | Should Be $true;
            Pop-Location;
        }

        It 'does not overwrite an existing file' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname;
            { $license = New-ModuleLicense -Path $relativePath -FullName $fullname -NoClobber -ErrorAction Stop; } | Should Throw;
            Pop-Location;
        }
    
    } #end context MIT Defaults

    Context 'Apache License' {
        $licenseType = 'Apache';

        It 'creates an Apache license' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName 'Iain Brighton' -LicenseType $licenseType;
            { (Get-Content -LiteralPath $license.FullName) -match 'Apache License\s+Version 2.0, January 2004' } | Should Be $true;
            Pop-Location;
        }

        It 'sets Apache license fullname' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname -LicenseType $licenseType;
            { (Get-Content -Path $relativePath) -match $fullname } | Should Be $true;
            { (Get-Content -Path $relativePath) -notmatch '{fullname}' } | Should Be $true;
            Pop-Location;
        }
    } #end context Apache License

    Context 'GPLv2 License' {
        $licenseType = 'GPLv2';

        It 'creates a GPLv2 license' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName 'Iain Brighton' -LicenseType $licenseType;
            { (Get-Content -LiteralPath $license.FullName) -match 'GNU GENERAL PUBLIC LICENSE\s+Version 2, June 1991' } | Should Be $true;
            Pop-Location;
        }

        It 'sets GPLv2 license fullname' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname -LicenseType $licenseType;
            { (Get-Content -Path $relativePath) -match $fullname } | Should Be $true;
            { (Get-Content -Path $relativePath) -notmatch '{fullname}' } | Should Be $true;
            Pop-Location;
        }

        It 'sets GPLv2 license project name' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname -Project $projectName -LicenseType $licenseType;
            { (Get-Content -Path $relativePath) -match $projectName } | Should Be $true;
            { (Get-Content -Path $relativePath) -notmatch '{project}' } | Should Be $true;
            Pop-Location;
        }
    } #end context GPLv2 License

    Context 'GPLv3 License' {
        $licenseType = 'GPLv3';

        It 'creates a GPLv3 license' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName 'Iain Brighton' -LicenseType $licenseType;
            { (Get-Content -LiteralPath $license.FullName) -match 'GNU GENERAL PUBLIC LICENSE\s+Version 3, 29 June 2007' } | Should Be $true;
            Pop-Location;
        }

        It 'sets GPLv2 license fullname' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname -LicenseType $licenseType;
            { (Get-Content -Path $relativePath) -match $fullname } | Should Be $true;
            { (Get-Content -Path $relativePath) -notmatch '{fullname}' } | Should Be $true;
            Pop-Location;
        }

        It 'sets GPLv2 license project name' {
            Push-Location -Path TestDrive:\;
            $license = New-ModuleLicense -Path $relativePath -FullName $fullname -Project $projectName -LicenseType $licenseType;
            { (Get-Content -Path $relativePath) -match $projectName } | Should Be $true;
            { (Get-Content -Path $relativePath) -notmatch '{project}' } | Should Be $true;
            Pop-Location;
        }
    } #end context GPLv3 License

} #end describe New-ModuleLicense

Describe 'Get-ModuleManifest' {
    $testModuleName = 'Test Module';
    $testModuleManifest = "$testModuleName.psd1";

    It 'returns a module manifest in current directory' {
        Push-Location -Path TestDrive:\
        New-Item -Path ".\$testModuleName" -ItemType Directory
        New-ModuleManifest -Path ".\$testModuleName\$testModuleManifest";
        (Get-ModuleManifest -Path ".\$testModuleName") -is [System.Management.Automation.PSModuleInfo] | Should Be $true;
        Pop-Location;
    }

    It 'returns the specified module manifest' {
        Push-Location -Path TestDrive:\
        if (-not (Test-Path -Path ".\$testModuleName")) { New-Item -Path ".\$testModuleName" -ItemType Directory; }
        New-ModuleManifest -Path ".\$testModuleName\$testModuleManifest";
        (Get-ModuleManifest -Path ".\$testModuleName\$testModuleManifest") -is [System.Management.Automation.PSModuleInfo] | Should Be $true;
        Pop-Location;
    }

    It 'errors when multiple module manifests are found' {
        Push-Location -Path TestDrive:\
        New-ModuleManifest -Path ".\$testModuleManifest";
        New-ModuleManifest -Path ".\$($testModuleName)2.psd1";
        { Get-ModuleManifest -Path '.\' -ErrorAction Stop; } | Should Throw;
        Pop-Location;
    }

    It 'errors when module manifest cannot be found' {
        Push-Location -Path TestDrive:\
        if (Test-Path -Path ".\$testModuleName\$testModuleManifest") { Remove-Item -Path ".\$testModuleName\$testModuleManifest"; }
        { Get-ModuleManifest -Path ".\$testModuleName" -ErrorAction Stop -Verbose; } | Should Throw;
        Pop-Location;
    }

} #end describe Get-ModuleManifest

<#
function Get-ModuleManifest {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([PSModuleInfo])]
    param (
        # One or more file paths to search for a module manifest file.
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [System.String[]] $Path = (Get-Location -PSProvider FileSystem),
        # One or more literal file paths to search for a module manifest file.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [System.String[]] $LiteralPath
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            for ($i = 0; $i -lt $Path.Length; $i++) { 
                $LiteralPath[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        }
    } #end begin
    process {
        foreach ($resolvedPath in $LiteralPath) {
            ## Do we have a file?        
            if (Test-Path -LiteralPath $resolvedPath -PathType Leaf) {
                ## Looks like it so assume this is a file..
                $ManifestPath = $resolvedPath;
            }
            else {
                ## We have a directory so attempt to resolve the manifest
                ## file as it should be the same as the directory name..
                $pathInfo = Get-Item -LiteralPath $resolvedPath;
                $ManifestPath = Join-Path -LiteralPath $pathInfo.FullName -ChildPath "$($pathInfo.Name).psd1";
                if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
                    ## Hmmm - let's see if there's a .psd1 in the folder
                    $psd1Files = Get-ChildItem -LiteralPath $resolvedPath -Filter '*.psd1';
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
            $moduleManifest = Test-ModuleManifest -LiteralPath $ManifestPath -ErrorAction SilentlyContinue;
            if (-not($?)) { throw 'Invalid module manifest file.'; }
            Write-Output $moduleManifest;
        } #end foreach Path
    } #end process
} #end function Get-ModuleManifest

#>