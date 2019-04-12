function Get-GitRevision {
<#
    .SYNOPSIS
        Returns the number of commits performed on the current branch of
        the local Git repository in the current working directory.
#>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Path = (Get-Location -PSProvider FileSystem).Path
    )
    process {
        [System.Int32] $revision = 0;
        if ((Test-Git) -and (Test-GitRepository -Path $Path)) {
            Write-Verbose -Message ($localized.QueryingGitCommitCount);
            $gitCommands = 'rev-list','HEAD','--count';
            Write-Debug ($localized.RunningGitCommand -f [System.String]::Join(' ', $gitCommands));
            $revisionCount = & git.exe $gitCommands
            Write-Debug ($localized.ParsingGitCommandOutput -f $revisionCount);
            [ref] $null = [System.Int32]::TryParse($revisionCount, [Ref] $revision)
        }
        Write-Output $revision;
    } #end process
} #end function
