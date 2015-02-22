## Import the VirtualEngine.Module.ps1 and VirtualEngine.Nuget.ps1 files. This permits
## loading of the module's functions for unit testing, without having to unload/load the module.
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath Licenses.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.Module.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.NuGet.ps1);
. (Join-Path -Path (Split-Path -Path $PSCommandPath) -ChildPath VirtualEngine.Git.ps1);

## Download Nuget.exe (if not present)
$moduleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path;
if (-not (Test-Path -Path "$moduleRoot\Lib\Nuget.exe")) {
    if (-not (Test-Path -Path "$moduleRoot\Lib" -PathType Container)) {
        [ref] $null = New-Item -Path "$moduleRoot\Lib" -ItemType Directory -Force;
    }
    Invoke-WebRequest -Uri 'http://nuget.org/nuget.exe' -OutFile "$moduleRoot\Lib\Nuget.exe";
}

## Export public functions
Export-ModuleMember -Function *-*;
