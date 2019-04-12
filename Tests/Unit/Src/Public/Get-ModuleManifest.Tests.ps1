$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe "VirtualEngine.Build\Get-ModuleManifest" {
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
    }
    
}
