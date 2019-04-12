function New-ModuleVersionNumber {
<#
    .SYNOPSIS
        Increments module version number with git commit count.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    [OutputType([System.Version])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path
    )
    process {
        $gitRevision = Get-GitRevision
        $currentVersion = Get-ModuleManifestProperty -Path $Path -Property Version
        return New-Object -TypeName System.Version -ArgumentList ($currentVersion.Major, $currentVersion.Minor, $gitRevision)
    }#end process
} #end function
