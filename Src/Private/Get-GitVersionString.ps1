function Get-GitVersionString {
<#
    .SYNOPSIS
        Returns a Git Tag.Revision in a System.Version formatted string.
    .DESCRIPTION
        Queries the latest tag of the current branch of the local Git
        repository in the current working directory - setting the revision
        number (last quartet of a Windows System.Version object) to the
        number of commits on the current branch.

        For example, if the Git repository is tagged as v1.2 with 73
        commits on the current branch, this cmdlet will return the
        '1.2.0.73' string.
#>
    [CmdletBinding()]
    param ( )
    process {
        $version = ConvertToAssemblyVersionArray -InputObject (Get-GitTag);
        $version[3] = Get-GitRevision;
        Write-Output (ConvertTo-AssemblyVersionString -InputObject $version);
    } #end process
} #end function
