function Get-GitHubProjectUri {
<#
    .SYNOPSIS
        Resolves GitHub project Url for the Git repository in the current
        working directory.
    .DESCRIPTION
        Queries the remote origin of the Git repository in the current working
        directory and ensures that it's a repository hosted on GitHub.
#>
    [CmdletBinding()]
    param ( )
    begin {
        if (-not (Test-Git)) {
            Write-Error ($localized.GitNotFoundError);
        }

    } #end begin
    process {
        $origin = Get-GitRemoteOrigin;
        if ($origin -inotmatch 'https:\/\/github.com\/.+\.git$') {
            Write-Error ($localized.NotGitHubRemoteOriginError -f $origin);
        }
        else {
            Write-Output ($origin.TrimEnd('git').TrimEnd('.'));
        }
    } #end process
} #end function
