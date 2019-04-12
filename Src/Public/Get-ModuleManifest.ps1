function Get-ModuleManifest {
<#
    .SYNOPSIS
        Gets a PowerShell module's manifest.
    .DESCRIPTION
        The Get-ModuleManifest cmdlet returns the properties of the specified PowerShell module's
        manifest.
    .EXAMPLE
        Get-ModuleManifest -Path .\Module1

        This example returns information about the PowerShell module contained in the 'Module1' directory.
    .EXAMPLE
        Get-ModuleManifest -Path .\Module1\Module.psd1

        This example returns information about the PowerShell module defined in the 'Module1\Module.psd1'
        manifest file. Use this option to return information from manifests not located in folders of the
        same name.
    .NOTES
        The Test-ModuleManifest does not support literal paths.
#>
    [CmdletBinding()]
    [OutputType([PSModuleInfo])]
    param (
        # One or more file paths to search for a module manifest file.
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')]
        [System.String[]] $Path = (Get-Location -PSProvider FileSystem)
    )
    begin {

        for ($i = 0; $i -lt $Path.Length; $i++) {
            $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }

    } #end begin
    process {

        foreach ($resolvedPath in $Path) {
            ## Do we have a file?
            if (Test-Path -Path $resolvedPath -PathType Leaf) {
                ## Looks like it so assume this is a file..
                $ManifestPath = $resolvedPath;
            }
            else {
                ## We have a directory so attempt to resolve the manifest
                ## file as it should be the same as the directory name..
                $pathInfo = Get-Item -Path $resolvedPath;
                $ManifestPath = Join-Path -Path $pathInfo.FullName -ChildPath "$($pathInfo.Name).psd1";
                if (-not (Test-Path -Path $ManifestPath -PathType Leaf)) {
                    ## Hmmm - let's see if there's a .psd1 in the folder
                    $psd1Files = Get-ChildItem -Path $resolvedPath -Filter '*.psd1';
                    if ($null -eq $psd1Files) {
                        Write-Error ($localized.NoMatchingManifestFileError -f $ManifestPath);
                    }
                    elseif ($psd1Files.Count -gt 1) {
                        Write-Error ($localized.MulitpleManifestFilesFoundError -f $Path);
                    }
                    else {
                        ## Use the discovered, single .psd1 file
                        $ManifestPath = $psd1Files.FullName;
                    }
                } #end if
            } #end if
            $moduleManifest = Test-ModuleManifest -Path $ManifestPath;
            Write-Output $moduleManifest;
        } #end foreach resolvedPath

    } #end process
} #end function
