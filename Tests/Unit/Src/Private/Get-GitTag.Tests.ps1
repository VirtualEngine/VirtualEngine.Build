$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = 'VirtualEngine.Build';
$moduleRoot = (Get-Item -Path "$here\..\..\..\..\").FullName
Import-Module "$moduleRoot\$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe 'VirtualEngine.Build\Get-GitTag' {
        Mock git.exe { }

        It "calls 'git.exe describe --abbrev=0 --tags'." {
            $null = Get-GitTag;
            Assert-MockCalled -CommandName git.exe -ParameterFilter { 'describe --abbrev=0 --tags' -eq $Args[0] };
        }
    }

}
