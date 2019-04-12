$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = 'VirtualEngine.Build';
$moduleRoot = (Get-Item -Path "$here\..\..\..\..\").FullName
Import-Module "$moduleRoot\$moduleName.psd1" -Force

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
