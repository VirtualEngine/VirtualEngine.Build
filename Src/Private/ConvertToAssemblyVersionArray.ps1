function ConvertToAssemblyVersionArray {
<#
    .SYNOPSIS
        Converts a version string to a four-part, integer array.
    .DESCRIPTION
        Converts a version string e.g. '1.2' to a full, four-part integer
        array e.g. 1, 2, 0, 0. This is typically used with Get-GitTag and
        Get-GitRevision cmdlets to create Tag.Revision numbers for
        MSBuild/PSake.
    .NOTES
        This cmdlet will ignore any trailing white spaces, periods or any
        string prefixed with 'v' or 'V'.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)] [ValidatePattern('[0-9]+(\.([0-9]+|\*)){1,3}')] [System.String] $InputObject
    )
    begin {
        $InputObject = $InputObject.TrimEnd('.').Trim();
        $InputObject = [System.Text.RegularExpressions.Regex]::Replace($InputObject, 'v', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase);
    }
    process {
        Write-Verbose ('Converting string ''{0}'' to a version.' -f $InputObject);
        $version = @(0, 0, 0, 0);
        $versionParts = $InputObject.Split('.');
        if ($versionParts.Length -gt 4) {
            Write-Warning ('Version string contains {0} parts. The maximum number of parts supported is 4.' -f $versionParts.Length);
        }
        for ($i = 0; $i -lt $versionParts.Length -and $i -lt 4; $i++) {
            try {
                $version[$i] = [System.Int32]::Parse($versionParts[$i]);
            } #end try
            catch {
                Write-Error ('Error parsing string ''{0}''. Ensure that $InputObject only includes numbers and periods.' -f $InputObject);
            } #end catch
        } #end for
        Write-Output $version -NoEnumerate;
    } #end process
} #end function
