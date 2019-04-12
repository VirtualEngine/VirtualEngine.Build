function Update-GitRepository {
<#
    .SYNOPSIS
        Updates (pulls) an existing Git repository
#>
    [CmdletBinding(SupportsShouldProcess)]
    param ( )
    begin {

        if (-not (Test-Git)) {
            throw ($localized.GitNotFoundError);
        }

        $currentPath = (Get-Location -PSProvider FileSystem).Path
        if (-not (Test-GitRepository -Path $currentPath)) {
            throw ($localized.GitRepositoryNotFoundError -f $currentPath);
        }

    } #end begin
    process {

        $gitCommands = 'pull';
        $gitCommandsString = [System.String]::Join(' ', $gitCommands)
        $gitString = 'git.exe {0}' -f $gitCommandsString
        Write-Debug ($localized.RunningGitCommand -f $gitCommandString);
        if ($PSCmdlet.ShouldProcess($pwd, $gitString)) {
            & git.exe $gitCommands
        }

    } #end process
} #end function
