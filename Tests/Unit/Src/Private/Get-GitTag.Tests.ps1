$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe 'VirtualEngine.Build\Get-GitTag' {
        Mock git.exe { }

        It "calls 'git.exe describe --abbrev=0 --tags'." {
            $null = Get-GitTag;
            Assert-MockCalled -CommandName git.exe -ParameterFilter { 'describe --abbrev=0 --tags' -eq $Args[0] };
        }
    }

}
