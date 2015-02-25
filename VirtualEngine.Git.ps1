function Get-GitTag {
    <#
        .SYNOPSIS
            Returns the latest Git tag for the current branch of the Git
            repository located in the current working directory.
    #>
    [CmdletBinding()]
    param ( )

    process {
        $gitCommand = 'git.exe describe --abbrev=0 --tags';
        Write-Verbose ("Running '{0}'." -f $gitCommand);
        Invoke-Expression -Command $gitCommand;
    } #end process
} #end function Get-GitTag

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
        Write-Output (ConvertToAssemblyVersionString -InputObject $version);
    } #end process
} #end Get-GitAssemblyVersionString

function ConvertToAssemblyVersionString {
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
} #end function Convert-ToAssemblyVersionString

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
} #end function Convert-ToAssemblyVersionString

function Get-GitRevision {
    <#
        .SYNOPSIS
            Returns the number of commits performed on the current branch of
            the local Git repository in the current working directory.
    #>
    [CmdletBinding()]
    param ( )

    process {
        $gitCommand = 'git.exe rev-list HEAD --count';
        Write-Verbose ("Running '{0}'." -f $gitCommand);;
        $revisionCount = Invoke-Expression -Command $gitCommand;
        Write-Verbose "Parsing output '$revisionCount'.";
        [System.Int32] $revision = 0;
        [Ref] $null = [System.Int32]::TryParse($revisionCount, [Ref] $revision)
        Write-Output $revision;
    } #end process
} #end function Get-GitRevision