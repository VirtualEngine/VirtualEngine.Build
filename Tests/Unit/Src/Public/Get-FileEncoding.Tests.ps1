$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleName = (Get-Item -Path "$here\..\..\..\..\").Name
Import-Module "$moduleName.psd1" -Force

InModuleScope $moduleName {
    Describe 'VirtualEngine.Build\Get-FileEncoding' {
        
        $testPath = 'TestDrive:\Get-FileEncodingTest.txt';
        $testContent = 'VirtualEngine.Build\Get-FileEncoding'
        
        It 'Reports ASCII encoding' {
            Set-Content -Path $testPath -Value $testContent -Encoding Ascii

            $encoding = (Get-FileEncoding -Path $testPath -WarningAction SilentlyContinue).HeaderName

            $encoding | Should Be 'us-ascii'
        }

        It 'Reports UTF-8 encoding' {
            Set-Content -Path $testPath -Value $testContent -Encoding UTF8

            $encoding = (Get-FileEncoding -Path $testPath).HeaderName

            $encoding | Should Be 'utf-8'
        }

        It 'Reports UTF-16BE encoding' {
            Set-Content -Path $testPath -Value $testContent -Encoding BigEndianUnicode

            $encoding = (Get-FileEncoding -Path $testPath).HeaderName

            $encoding | Should Be 'utf-16BE'
        }

        It 'Reports UTF-32 encoding' {
            Set-Content -Path $testPath -Value $testContent -Encoding Unicode

            $encoding = (Get-FileEncoding -Path $testPath).HeaderName

            $encoding | Should Be 'utf-32'
        }
    }
}
