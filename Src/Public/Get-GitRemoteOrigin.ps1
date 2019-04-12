function Get-GitRemoteOrigin {
<#
    .SYNOPSIS
        Retrieves the remote origin of the Git repository
        located in the current working directory.
#>
    [CmdletBinding()]
    param ( )
    begin {

        if (-not (Test-Git)) {
            throw ($localized.GitNotFoundError);
        }

        $currentPath = (Get-Location -PSProvider FileSystem).Path
        if (-not (Test-GitRepository -Path $currentPath)) {
            throw ($localized.GitRepositoryNotFoundError -f $currentPath);
        }

    }
    process {

        Write-Verbose -Message ($localized.QueryingGitRemote);
        $gitCommands = 'config','--get','remote.origin.url';
        Write-Debug ($localized.RunningGitCommand -f [System.String]::Join(' ', $gitCommands));
        [System.String] $origin = & git.exe $gitCommands; # Returns nothing if it's not a Git repo

        if ([System.String]::IsNullOrEmpty($origin)) {
            Write-Error ($localized.GitRemoteNotConfiguredError);
        }
        else {
            Write-Verbose -Message ($localized.GitRemoteFound -f $origin);
            Write-Output $origin;
        }

    } #end process
} #end function
