$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = 'VirtualEngine.Build';
$moduleRoot = (Get-Item -Path "$here\..\..\..\..\").FullName
Import-Module "$moduleRoot\$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe "VirtualEngine.Build\Test-Git" {

        # Guard mocks
        Mock Get-Command

        It "Returns 'true' when 'git.exe' is found" {
            Mock Get-Command { @{ CommandType = 'Application' } }
            Test-Git | Should Be $true;
        }

        It "Returns 'false' when 'git.exe' is found" {
            Mock Get-Command { Write-Error 'Not found' }
            Test-Git | Should Be $false;
        }
    }
}
