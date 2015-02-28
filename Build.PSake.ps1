#requires -Module VirtualEngine.Build, VirtualEngine.Compression;
#requires -Version 3;

<#
## Github Powershell Project Releases

 1. PSake - Clean
  1.1 Remove the Build\ directory

 2. PSake - Build
  2.1 Create Build\ directory

 3. PSake - Test
  3.1 Invoke-Pester
  3.2 Right output xml to Build\ directory

 4. PSake - Release/Stage
  4.1 Create build\ModuleName directory
  4.2 Copy required files into build\ModuleName directory
  4.3 Update module manifest with version number
  4.4 Sign files
  4.5 Zip build\ModuleName directory to release\ModuleName-v1.2.3.4.zip

 5. PSake - Publish/Release

  5.1 Github
   5.1.1 Tag local repo with version number
          - requires encryption of ApiKey
   5.1.2 Create change log/release notes (#changelog in commit message?)
   5.1.3 Create Github Release with version number and change log
   5.1.4 Upload artifact/asset

  5.2 Chocolatey
   5.2.1 Create \Chocolatey directory
   5.2.2 Deploy ChocolateyInstall.ps1 and ChocolateyUninstall.ps1
   5.2.3 Create Nuspec: release\ModuleName-v1.2.3.4.nuspec
          - download URL from asset upload
   5.2.4 Push Nuspec to Chocolatey
          - requires encryption of ApiKey
  
  5.3 PowershellGet
    5.3.1 Should be able to push the release\ModuleName folder?
#>

Properties {
    $currentDir = Resolve-Path -Path .;
    $basePath = $psake.build_script_dir;
    $buildDir = 'Build';
    $releaseDir = 'Release';
    $invocation = (Get-Variable MyInvocation -Scope 1).Value;
    $thumbprint = 'D10BB31E5CE3048A7D4DA0A4DD681F05A85504D3';
    $timeStampServer = 'http://timestamp.verisign.com/scripts/timestamp.dll';
    $company = 'Virtual Engine Limited';
    $author = 'Iain Brighton';
}

Task Default -Depends Setup, Clean, Version, Build, Test;

Task Stage -Depends Default, Sign {
    ## Creates the release files in the $releaseDir
    $releaseName = '{0}-v{1}' -f $manifest.Name, $version;

    ## Create module zip
    $zipReleaseName = '{0}.zip' -f $releaseName;
    $zipPath = Join-Path -Path $releasePath -ChildPath $zipReleaseName;
    ## Zip the parent directory
    $zipSourcePath = Split-Path -Path $buildPath -Parent;
    New-ZipArchive -Path $zipSourcePath -DestinationPath $zipPath;

    ## Create the Chocolatey package
    $nuspecFilename = '{0}.nuspec' -f $manifest.Name;
    $nuspecPath = Join-Path -Path $chocolateyBuildPath -ChildPath $nuspecFilename;
    Write-Host (' - 3: {0}' -f $manifest.Version) -ForegroundColor Cyan;
    (New-NuGetNuspec -InputObject $manifest).Save($nuspecPath);
    New-ChocolateyInstallModule -Path "$chocolateyBuildPath\tools" -PackageName $manifest.Name -Uri $manifest.PrivateData.PSData.ProjectUri;
    Invoke-NuGetPack -Path $nuspecPath -DestinationPath $releasePath;
}

Task Publish -Depends Stage {

}

Task Setup {
    # Properties are not available in the script scope.
    Set-Variable manifest -Value (Get-ModuleManifest) -Scope Script;
    Set-Variable buildPath -Value (Join-Path -Path $psake.build_script_dir -ChildPath "$buildDir\$($manifest.Name)") -Scope Script;
    Set-Variable chocolateyBuildPath -Value (Join-Path -Path $psake.build_script_dir -ChildPath "$buildDir\Chocolatey") -Scope Script;
    Set-Variable releasePath -Value (Join-Path -Path $psake.build_script_dir -ChildPath $releaseDir) -Scope Script;

    Set-Variable version -Value (Get-GitVersionString) -Scope Script;

    Write-Host (' Building module "{0}".' -f $manifest.Name) -ForegroundColor Yellow;
    Write-Host (' Using Git version "{0}".' -f $version) -ForegroundColor Yellow;
}

Task Clean {
    ## Remove build directory
    $baseBuildPath = Join-Path -Path $psake.build_script_dir -ChildPath $buildDir;
    if (Test-Path -Path $baseBuildPath) {
        Write-Host (' Removing build base directory "{0}".' -f $baseBuildPath) -ForegroundColor Yellow;
        Remove-Item $baseBuildPath -Recurse -Force -ErrorAction Stop;
    }
}

Task Build {
    ## Create the build directory
    Write-Host (' Creating build directory "{0}".' -f $buildPath) -ForegroundColor Yellow;
    [Ref] $null = New-Item $buildPath -ItemType Directory -Force -ErrorAction Stop;
    ## Create the release directory
    if (!(Test-Path -Path $releasePath)) {
        Write-Host (' Creating release directory "{0}".' -f $releasePath) -ForegroundColor Yellow;
        [Ref] $null = New-Item $releasePath -ItemType Directory -Force -ErrorAction Stop;
    }  
    ## Create the Chocolatey folder
    Write-Host (' Creating Chocolatey directory "{0}".' -f $chocolateyBuildPath) -ForegroundColor Yellow;
    [Ref] $null = New-Item $chocolateyBuildPath -ItemType Directory -Force -ErrorAction Stop;
    [Ref] $null = New-Item "$chocolateyBuildPath\tools" -ItemType Directory -Force -ErrorAction Stop;

    ## Copy release files
    Write-Host (' Copying release files to build directory "{0}".' -f $buildPath) -ForegroundColor Yellow;
    $excludedFiles = @( '*.Tests.ps1','Build.PSake.ps1','Chocolatey*','.git*' );
    Get-ModuleFile -Exclude $excludedFiles | Copy-Item -Destination $buildPath -Recurse;

    ## Update license
    $licensePath = Join-Path -Path $buildPath -ChildPath LICENSE;
    Write-Host (' Creating license file "{0}".' -f $licensePath) -ForegroundColor Yellow;
    [Ref] $null = New-ModuleLicense -Path $licensePath -LicenseType MIT -FullName $company;
}

Task Version {
    ## Version module manifest prior to build
    Write-Host (' Versioning module manifest "{0}".' -f $buildManifest.Path) -ForegroundColor Yellow;
    Set-ModuleManifestProperty -Path $manifest.Path -Version $version -CompanyName $company -Author $author;
    ## Reload module manifest
    Write-Host (' - 1: {0}' -f $manifest.Version) -ForegroundColor Cyan;
    $manifest = Get-ModuleManifest;
    Write-Host (' - 2: {0}' -f $manifest.Version) -ForegroundColor Cyan;
}

Task Sign {
    Get-ChildItem -Path $buildPath -Include *.ps* -Recurse -File | % {
        Write-Host (' Signing file "{0}":' -f $PSItem.FullName) -ForegroundColor Yellow -NoNewline;
        $signResult = Set-ScriptSignature -Path $PSItem.FullName -Thumbprint $thumbprint -TimeStampServer $timeStampServer -ErrorAction Stop;
        Write-Host (' {0}.' -f $signResult.Status) -ForegroundColor Green;
    }
}

Task Test {
    $testResultsPath = Join-Path $buildPath -ChildPath 'NUnit.xml';
    $testResults = Invoke-Pester -Path $basePath -OutputFile $testResultsPath -OutputFormat NUnitXml -PassThru -Strict;
    if ($testResults.FailedCount -gt 0) {
        Write-Error ('{0} unit tests failed.' -f $testResults.FailedCount);
    }
}

<#
task CreateReleaseZipDirectory {
    Remove-Item -Path $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue;
    [ref] $null = New-Item -Path $zipDirectory -ItemType Container;
}

task StageReleaseZipFiles -depends CreateReleaseZipDirectory {

    $codeSigningCert = Get-ChildItem Cert:\ -CodeSigningCert -Recurse | Where Thumbprint -eq $Properties.CertificateThumbprint;

    foreach ($moduleFile in Get-ModuleFiles) {
        Copy-Item -Path $moduleFile.FullName -Destination $zipDirectory -Force;

        if ($moduleFile.Extension -in '.ps1','.psm1') {
            $moduleFilePath = Join-Path $zipDirectory $moduleFile.Name;
            Write-Verbose ("Signing file '{0}'." -f $moduleFilePath);
            $signResult = Set-ScriptSigntaure -Path $moduleFilePath -Thumbprint $Properties.CertificateThumbprint -TimeStampServer $Properties.TimeStampServer;
        }
    }
}

task CreateReleaseZip -depends StageReleaseZipFiles {
    $releaseDirectory = Resolve-Path (Join-Path . $Properties.ReleaseDirectory);
    $zipFileName = Join-Path $releaseDirectory ("{0}.zip" -f $packageName);
    Write-Verbose ("Zip release path '{0}'." -f $zipFileName);
    $zipFile = New-ZipArchive -Path $tempDirectory -DestinationPath $zipFileName;
    Write-Verbose ("Zip archive '{0}' created." -f $zipFile.FullName);
}

task CreateChocolateyReleaseDirectory {
    Remove-Item -Path $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue;
    [ref] $null = New-Item -Path $tempDirectory -ItemType Container;
    [ref] $null = New-Item -Path "$tempDirectory\tools" -ItemType Container;
}

task StageChocolateyReleaseFiles -depends CreateChocolateyReleaseDirectory {
    ## Create .nuspec
    $nuspec = $module | New-NugetNuspec -LicenseUrl $Properties.LicenseUrl;
    $nuspecFilename = "$($module.Name).nuspec";
    $nuspecPath = Join-Path $tempDirectory $nuspecFilename;
    $nuspec.Save($nuspecPath);

    ## Create \Tools\ChocolateyInstall.ps1
    $chocolateyInstallPath = Join-Path (Get-Location) 'ChocolateyInstall.ps1'; 
    Copy-Item -Path $chocolateyInstallPath -Destination "$tempDirectory\tools\" -Force;

    ## Add Install-ChocolateyZipPackage to the ChocolateyInstall.ps1 file with the relevant download link
    $downloadUrl = "$($Properties.DownloadBaseUrl)/$packageName.zip";
    $installChocolateyZipPackage = "Install-ChocolateyZipPackage '{0}' '{1}' '$userPSModulePath';" -f $packageName, $downloadUrl;
    Add-Content -Path "$tempDirectory\tools\ChocolateyInstall.ps1" -Value $installChocolateyZipPackage;
}

task CreateChocolateyReleasePackage -depends StageChocolateyReleaseFiles {
    
    $releaseDirectory = Resolve-Path (Join-Path . $Properties.ReleaseDirectory);
    Push-Location $tempDirectory;
    Invoke-Expression -Command ('Nuget Pack "{0}" -OutputDirectory "{1}"' -f $nuspecFileName, $releaseDirectory);
    Pop-Location;
}

task PushReleaseZip -depends CreateReleaseZip {
    Import-Module Posh-SSH;

}

task RemoveReleaseDirectory {
    Remove-Item -Path $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue;
}
#>