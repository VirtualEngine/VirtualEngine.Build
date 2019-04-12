$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe 'VirtualEngine.Build\Get-GitVersionString' {

        It "outputs 1.2.0.48" {
            Mock Get-GitTag { Write-Output '1.2' };
            Mock Get-GitRevision { Write-Output 48 };
            Get-GitVersionString | Should BeExactly '1.2.0.48';
        }
    
        It "outputs 1.0.3.97" {
            Mock Get-GitTag { Write-Output 'v1.0.3' };
            Mock Get-GitRevision { Write-Output 97 };
            Get-GitVersionString | Should BeExactly '1.0.3.97';
        }
    }
    
}
