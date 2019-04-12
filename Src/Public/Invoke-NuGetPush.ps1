function Invoke-NuGetPush {
<#
    .SYNOPSIS
        Pushes the specified NuGet .nupkg package.
    .NOTES
        https://github.com/chocolatey/chocolatey/blob/master/src/functions/Chocolatey-Push.ps1
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        # File path to the NuGet .nupkg source file to pack.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        # Nuget Api Key.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ApiKey,

        # Nuget source feed. Defaults to the Chocolatey public feed.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Source = 'https://chocolatey.org/'
    )
    begin {

        if (Test-Path -Path $Path -PathType Container) {
            Write-Error ($localized.DirectoryPathSpecifyNupkgError -f $Path);
            break;
        }
        $nupkg = Get-Item -Path $Path;
        if ($nupkg.Extension -ne '.nupkg') {
            Write-Error ($localized.InvalidNupkgPathError -f $Path);
            break;
        }

    } #end begin
    process {

        $nugetDirectoryPath = Split-Path $virtualEngineBuildNugetPath -Parent;
        $packageArgs = 'push "{0}" -ApiKey {1} -Source {2} -NonInteractive' -f $nupkg.Fullname, $ApiKey, $Source;
        $logFile = Join-Path -Path $nugetDirectoryPath -ChildPath 'push.log';
        $errorLogFile = Join-Path -Path $nugetDirectoryPath -ChildPath 'error.log';

        Write-Verbose -Message ($localized.StartingProcessWithArgs -f $virtualEngineBuildNugetPath, $packageArgs);
        $process = Start-Process $virtualEngineBuildNugetPath -ArgumentList $packageArgs -NoNewWindow -Wait -RedirectStandardOutput $logFile -RedirectStandardError $errorLogFile -PassThru;

        # this is here for specific cases in Posh v3 where -Wait is not honored
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
