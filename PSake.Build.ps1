#requires -Module VirtualEngine.Build;
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
  4.3 Sign files
  4.4 Update module manifest with version number
  4.5 Zip build\ModuleName directory to release\ModuleName-v1.2.3.4.zip

 5. PSake - Publish/Release

  5.1 Github
   5.1.1 Tag local repo with version number
          - requires encryption of ApiKey
   5.1.2 Create change log/release notes (#changelog in commit message?)
   5.1.3 Create Github Release with version number and change log
   5.1.4 Upload artifact/asset

  5.2 Chocolatey
   5.2.1 Create Nuspec: release\ModuleName-v1.2.3.4.nuspec
          - download URL from asset upload
   5.2.2 Push Nuspec to Chocolatey
          - requires encryption of ApiKey
  
  5.3 PowershellGet
    3.3.1 Should be able to push the release\ModuleName folder?
#>

properties {
    $currentDir = Resolve-Path -Path .;
    $basePath = $psake.build_script_dir;
    $buildPath = Join-Path -Path $psake.build_script_dir -ChildPath Build;
    $releaseDir = Join-Path -Path $psake.build_script_dir -ChildPath Release;
    $invocation = (Get-Variable MyInvocation -Scope 1).Value;
    $thumbprint = 'D10BB31E5CE3048A7D4DA0A4DD681F05A85504D3';
    $timeStampServer = 'http://timestamp.verisign.com/scripts/timestamp.dll';
}

#$buildPath = Join-Path -Path $baseDir -ChildPath $buildDir;
#$releasePath = Join-Path -Path $baseDir -ChildPath $releaseDir;
#$manifest = Get-ModuleManifest;
#$version = Get-GitVersionString;
#$packageName = '{0}-v{1}' -f $manifest.Name, $version;

Task Default -Depends Clean, Build, Test;

Task Stage -Depends Default {

}

Task Publish -Depends Stage {

}

Task Clean {
    Write-Host "'$basePath'";
    Write-Host "'$buildPath'";

}

Task Build {

}

Task Test {

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