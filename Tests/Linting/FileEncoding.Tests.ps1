$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Describe 'Linting\FileEncoding' {

    $excludedPaths = @(
        '.git*',
        '.vscode',
        'Release',
        'Buid',
        'Lib',
        '*.png',
        'TestResults.xml'
    );
    
    Get-ChildItem -Path $repoRoot -Exclude $excludedPaths |
        ForEach-Object {
            Get-ChildItem -Path $_.FullName -Recurse |
                ForEach-Object {

                    if ($_ -is [System.IO.FileInfo])
                    {
                        It "File '$($_.FullName.Replace($repoRoot,''))' uses UTF-8 (no BOM) encoding" {
                            $encoding = (Get-FileEncoding -Path $_.FullName -WarningAction SilentlyContinue).HeaderName
                            $encoding | Should Be 'us-ascii'
                        }
                    }
                }
        }
}
