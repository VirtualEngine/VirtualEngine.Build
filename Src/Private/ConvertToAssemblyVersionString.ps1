function ConvertTo-AssemblyVersionString {
<#
    .SYNOPSIS
        Converts an array of integers to version string.
    .DESCRIPTION
        Converts an array of integers, e.g. 1,2,0,0 to a System.Version
        formatted string, e.g. '1.2.0.0'.

        This is typically used after converting a Git tag with the Get-GitTag
        cmdlet and updating the revision with the Get-GitRevision cmdlet to
        create a full Tag.Revision number to update assembly references prior
        to MSBuild/PSake compilation.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)] [System.Array] $InputObject
    )
    process {
        Write-Output ([System.String]::Join('.', $InputObject));
    } #end process
} #end function
