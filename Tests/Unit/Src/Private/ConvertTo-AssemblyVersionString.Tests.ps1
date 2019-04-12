$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe 'VirtualEngine.Build\ConvertToAssemblyVersionArray' {

        It "converts 1.2 to 1,2,0,0" {
            [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2')) | Should Be ([String]::Join(',', @(1,2,0,0)));
        }
    
        It "converts 1.2.3 to 1,2,3,0" {
            [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2.3')) | Should Be ([String]::Join(',', @(1,2,3,0)));
        }
    
        It "converts 1.2.3.4 to 1,2,3,4" {
            [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
        }
        
        It "converts prefixed v1.2.3.4 to 1,2,3,4" {
            [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject 'v1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
        }
    
        It "converts prefixed V1.2.3.4 to 1,2,3,4" {
            [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject 'V1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
        }
    
        It "truncates 1.2.3.4.5 to 1,2,3,4" {
            [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2.3.4.5' -WarningAction SilentlyContinue)) | Should Be ([String]::Join(',', @(1,2,3,4)));
        }
    
        It "truncates prefixed v1.2.3.4.5 to 1,2,3,4" {
            [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject 'V1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
        }
    
        It "throws on invalid version string '1'." {
            { ConvertToAssemblyVersionArray -InputObject '1' -ErrorAction Stop } | Should Throw;
        }
    
        It "throws on invalid version string '1.2.a'." {
            { ConvertToAssemblyVersionArray -InputObject '1.2.a' -ErrorAction Stop } | Should Throw;
        }
    
        It "throws on String.Empty input" {
            { ConvertToAssemblyVersionArray -InputObject ([String]::Empty) } | Should Throw;
        }
    }
    
}
