function Test-Git {
<#
    .SYNOPSIS
        Checks that Git is installed and located on the system path.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ( )
    process {
        Write-Verbose -Message ($localized.TestingGit);
        $git = Get-Command -Name 'Git.exe' -ErrorAction SilentlyContinue;
        if ($git.CommandType -eq 'Application') {
            $gitCommands = '--version';
            Write-Debug ($localized.RunningGitCommand -f [System.String]::Join(' ', $gitCommands));
            $gitVersion = git.exe $gitCommands
            Write-Debug -Message ($localized.DetectedGitVersion -f $gitVersion);
            return $true;
        }
        return $false;
    } #end process
} #end function
