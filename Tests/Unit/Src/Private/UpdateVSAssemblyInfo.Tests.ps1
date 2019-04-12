$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe 'VirtualEngine.Build\Update-VSAssemblyInfo' {

        $assemblyInfo = @(
            '[assembly: AssemblyTitle("Assembly Title")]',
            '[assembly: AssemblyDescription("Assembly Description")]',
            '[assembly: AssemblyConfiguration("Assembly Configuration")]',
            '[assembly: AssemblyCompany("Assembly Company")]',
            '[assembly: AssemblyProduct("VirtualEngine.Library")]',
            '[assembly: AssemblyCopyright("Copyright © 2015")]',
            '[assembly: AssemblyTrademark("Assembly Trademark")]',
            '[assembly: AssemblyCulture("")]',
            '[assembly: ComVisible(false)]',
            '[assembly: Guid("03538a49-f433-4644-9e2b-e0a5b34f2b95")]',
            '[assembly: AssemblyVersion("1.0.0.0")]',
            '[assembly: AssemblyFileVersion("1.0.0.0")]'
        );

        It "doesn't change anything." {
            $assemblyInfo | Update-VSAssemblyInfo | Should BeExactly $assemblyInfo;
        }
        
        It 'updates a 2 digit AssemblyVersion attribute.' {
            $expected = '[assembly: AssemblyVersion("1.2")]'
            '[assembly: AssemblyVersion("")]' | Update-VSAssemblyInfo -Version '1.2' | Should BeExactly $expected;
        }
    
        It 'updates a 3 digit AssemblyVersion attribute.' {
            $expected = '[assembly: AssemblyVersion("1.2.3")]'
            '[assembly: AssemblyVersion("")]' | Update-VSAssemblyInfo -Version '1.2.3' | Should BeExactly $expected;
        }
    
        It 'updates a 4 digit AssemblyVersion attribute.' {
            $expected = '[assembly: AssemblyVersion("1.2.3.4")]'
            '[assembly: AssemblyVersion("")]' | Update-VSAssemblyInfo -Version '1.2.3.4' | Should BeExactly $expected;
        }
    
        It 'throws with an invalid AssemblyVersion attribute.' {
            { '[assembly: AssemblyVersion("")]' | Update-VSAssemblyInfo -Version '1' } | Should Throw;
        }
    
        It 'updates a 2 digit AssemblyFileVersion attribute.' {
            $expected = '[assembly: AssemblyFileVersion("1.2")]'
            '[assembly: AssemblyFileVersion("")]' | Update-VSAssemblyInfo -FileVersion '1.2' | Should BeExactly $expected;
        }
    
        It 'updates a 3 digit AssemblyFileVersion attribute.' {
            $expected = '[assembly: AssemblyFileVersion("1.2.3")]'
            '[assembly: AssemblyFileVersion("")]' | Update-VSAssemblyInfo -FileVersion '1.2.3' | Should BeExactly $expected;
        }
    
        It 'updates a 4 digit AssemblyFileVersion attribute.' {
            $expected = '[assembly: AssemblyFileVersion("1.2.3.4")]'
            '[assembly: AssemblyFileVersion("")]' | Update-VSAssemblyInfo -FileVersion '1.2.3.4' | Should BeExactly $expected;
        }
    
        It 'throws with an invalid AssemblyFileVersion attribute.' {
            { '[assembly: AssemblyFileVersion("")]' | Update-VSAssemblyInfo -FileVersion '1' } | Should Throw;
        }
    
        It 'updates a blank AssemblyTitle attribute.' {
            $expected = '[assembly: AssemblyTitle("My Title")]'
            '[assembly: AssemblyTitle("")]' | Update-VSAssemblyInfo -Title 'My Title' | Should BeExactly $expected;
        }
    
        It 'overwrites an existing AssemblyDescription attribute.' {
            $expected = '[assembly: AssemblyDescription("My Description")]'
            '[assembly: AssemblyDescription("My Old Description")]' | Update-VSAssemblyInfo -Description 'My Description' | Should BeExactly $expected;
        }
    
        It 'updates an existing collection.' {
            $result = ($assemblyInfo | Update-VSAssemblyInfo -Company 'My Company');
            $result -match '\[assembly: AssemblyCompany\("My Company"\)\]' | Should Not Be $null;
            ($result -notmatch '\[assembly: AssemblyCompany\("My Company"\)\]').Count | Should Be 11;
        }
    }
    
}
