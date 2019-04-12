function TestChocolateyInstallPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path
    )
    process {
        if (Test-Path -Path $Path -PathType Leaf) {
            Write-Error ('Path "{0}" is not a directory.' -f $Path);
            Write-Output $false;
        }
        if ($Path -notmatch '\\tools\\?') {
            Write-Warning ('Path "{0}" does not include the \tools directory. Chocolatey install files should be placed into this directory.' -f $Path);
        }
        Write-Output $true;
    } #end process
} #end function TestChocolateyInstallPath
