function Copy-GitRepository {
<#
    .SYNOPSIS
        Clones a Git repository
#>
    [CmdletBinding()]
    param (
        ## Git repository Uri
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        ## Clone only a specific Git branch
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Branch,

        ## Update if Git repository already exists
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        if (-not (Test-Git)) {
            throw ($localized.GitNotFoundError);
        }

    } #end begin
    process {

        $currentPath = (Get-Location -PSProvider FileSystem).Path
        $isGitRepository = Test-GitRepository -Path $currentPath;
        if ($isGitRepository -and (-not $Force)) {
            throw ($localized.GitRepositoryFoundError -f $currentPath);
        }
        elseif ($isGitRepository -and $Force) {
            ## Update repository
            Update-GitRepository -Verbose:$false;
        }
        else {
            ## Clone repository
            $gitCommands = 'clone', $Uri, '.'
            Write-Debug ($localized.RunningGitCommand -f [System.String]::Join(' ', $gitCommands));
            & git.exe $gitCommands
        }

    } #end process
} #end function
