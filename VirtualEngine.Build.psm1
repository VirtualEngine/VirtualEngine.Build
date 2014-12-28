## Import the VirtualEngine.Module.ps1 and VirtualEngine.Nuget.ps1 files. This permits
## loading of the module's functions for unit testing, without having to unload/load the module.
. (Join-Path (Split-Path $PSCommandPath) VirtualEngine.Module.ps1);
. (Join-Path (Split-Path $PSCommandPath) VirtualEngine.NuGet.ps1);

## Export public functions
Export-ModuleMember -Function *-*;
