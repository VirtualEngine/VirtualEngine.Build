function Test-GitRemoteOrigin {
<#
    .SYNOPSIS
        Tests if the Git repository located in the current working directoty
        has a remote origin configured.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ( )
    process {

        $gitRemoteOrigin = Get-GitRemoteOrigin -ErrorAction SilentlyContinue;

        if (-not ($gitRemoteOrigin)) {
            Write-Verbose -Message ($localized.GitRemoteNotConfiguredError);
            return $false;
        }

        return $true;

    } #end process
} #end function
