function Get-GitTag {
<#
    .SYNOPSIS
        Returns the latest Git tag for the current branch of the Git
        repository located in the current working directory.
#>
    [CmdletBinding()]
    param ( )

    process {
        $gitCommands = 'describe','--abbrev=0','--tags';
        Write-Debug ($localized.RunningGitCommand -f [System.String]::Join(' ', $gitCommands));
        & git.exe $gitCommands
    } #end process
} #end function
