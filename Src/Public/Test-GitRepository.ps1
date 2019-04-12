function Test-GitRepository {
<#
    .SYNOPSIS
        Tests whether the supplied path is a Git repository
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Path = (Get-Location -PSProvider FileSystem).Path
    )
    process {
        $gitPath = Join-Path -Path $Path -ChildPath '.git';
        Write-Verbose -Message ($localized.TestingGitRepository -f $Path);
        return (Test-Path -Path $gitPath -PathType Container);
    }
} #end function
