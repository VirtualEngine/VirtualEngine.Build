$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

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
