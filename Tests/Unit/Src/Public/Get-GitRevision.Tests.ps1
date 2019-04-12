$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

InModuleScope $moduleName {

    Describe "VirtualEngine.Build\Get-GitRevision" {
        Mock 'Test-Git' { $true }
        Mock 'git.exe' { }

        It "calls 'git.exe rev-list HEAD --count'." {
            $null = Get-GitRevision
            Assert-MockCalled -CommandName git.exe -ParameterFilter { 'rev-list HEAD --count' -eq $Args[0] };
        }
    }

}
