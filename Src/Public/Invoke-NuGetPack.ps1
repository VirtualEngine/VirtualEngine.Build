function Invoke-NuGetPack {
<#
    .SYNOPSIS
        Packs the specified NuGet .nuspec package.
    .NOTES
        https://github.com/chocolatey/chocolatey/blob/master/src/functions/Chocolatey-Pack.ps1
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        # File path to the NuGet .nuspec source file to pack.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        # Output directory path for the NuGet package.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $DestinationPath
    )
    begin {

        if (Test-Path -Path $Path -PathType Container) {
            Write-Error ($localized.DirectoryPathSpecifyNuspecError -f $Path);
            break;
        }
        $nuspec = Get-Item -Path $Path;
        if ($nuspec.Extension -ne '.nuspec') {
            Write-Error ($localized.InvalidNuspecPathError -f $Path);
            break;
        }

    }
    process {

        $nugetDirectoryPath = Split-Path $virtualEngineBuildNugetPath -Parent;
        $packageArgs = 'pack "{0}" -NoPackageAnalysis -NonInteractive -OutputDirectory "{1}"' -f $nuspec.Fullname, $DestinationPath;
        $logFile = Join-Path -Path $nugetDirectoryPath -ChildPath 'pack.log';
        $errorLogFile = Join-Path -Path $nugetDirectoryPath -ChildPath 'error.log';

        Write-Verbose -Message ($localized.StartingProcessWithArgs -f $virtualEngineBuildNugetPath, $packageArgs);
        $process = Start-Process $virtualEngineBuildNugetPath -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile -PassThru;

        # this is here for specific cases in Posh v3 where -Wait is not honoured
        try {
            if (-not ($process.HasExited)) {
                Wait-Process -Id $process.Id;
            }
        }
        catch { Write-Debug -Message $_.Exception.Message }

        Get-Content -Path $logFile -Encoding Ascii;
        if ($process.ExitCode -ne 0) {
            $errors = Get-Content $errorLogFile;
            foreach ($e in $errors) {
                Write-Error $e;
            }
        }

    } #end process
} #end function
