## Import the VirtualEngine .ps1 files. This permits loading of the module's functions
## for unit testing, without having to unload/load the module.
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath Licenses.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.Module.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.NuGet.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.Git.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.Github.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.VisualStudio.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.Chocolatey.ps1);

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

## Export public functions
Export-ModuleMember -Function *-*;
