
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture)) {
    $culture = $PSUICulture
}
$importLocalizedDataParams = @{
    BindingVariable = 'localized';
    Filename = 'VirtualEngine.Build.psd1';
    BaseDirectory = $moduleRoot;
    UICulture = $culture;
}
Import-LocalizedData @importLocalizedDataParams;
#endregion LocalizedData

## Dot source all (nested) .ps1 files in the folder, excluding Pester tests
$srcPath = Join-Path -Path $moduleRoot -ChildPath 'Src'
Get-ChildItem -Path $srcPath -Include *.ps1 -Recurse |
ForEach-Object {
    Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
    ## https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
    . ([System.Management.Automation.ScriptBlock]::Create(
            [System.IO.File]::ReadAllText($_.FullName)
        ));
}

## Download Nuget.exe (if not present)
$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path;
Set-Variable -Name virtualEngineBuildNugetPath -Value (Join-Path -Path $moduleRoot -ChildPath 'Lib\Nuget.exe') -Scope Script;
if (-not (Test-Path -Path $virtualEngineBuildNugetPath)) {
    $virtualEngineBuildNugetParentPath = Split-Path -Path $virtualEngineBuildNugetPath -Parent;
    if (-not (Test-Path -Path $virtualEngineBuildNugetParentPath -PathType Container)) {
        [ref] $null = New-Item -Path $virtualEngineBuildNugetParentPath -ItemType Directory -Force;
    }
    Invoke-WebRequest -Uri 'http://nuget.org/nuget.exe' -OutFile $virtualEngineBuildNugetPath;
}
