function GetModuleExcludedFile {
<#
    .SYNOPSIS
        Returns files to be excluded from a module release.
    .DESCRIPTION
        The GetModuleExcludedFiles cmdlets returns all files that are excluded from a module
        release. Properties of the .gitignore and .gitattributes files are parsed to determine
        which files are not required in a release bundle.
    .NOTES
        This is an internal module function that is not intended to be called directly.
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        # One or more file paths to enumerate.
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')]
        [System.String] $Path = (Get-Location -PSProvider FileSystem),

        # One or more literal file paths to enumerate.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            $Path = $LiteralPath;
        } # end if
        if (-not (Test-Path -Path $Path -PathType Container)) {
            Write-Error ($localized.NotDirectoryPathError -f $Path);
        }

    } #end begin
    process {

        ## Parse .gitignore
        $gitIgnorePath = Join-Path -Path $Path -ChildPath '.gitignore';
        if (-not (Test-Path -Path $gitIgnorePath -PathType Leaf)) {
            Write-Verbose -Message ($localized.NoGitIgnoreFound -f $Path);
        }
        else {
            $gitIgnores = Get-Content -Path $gitIgnorePath -Force;
            foreach ($gitIgnore in $gitIgnores) {
                ## Check whether we have a directory
                if ($gitIgnore.Contains('/')) {
                    if (-not ($gitIgnore.StartsWith('/'))) {
                        ## Test path requires a leading \
                        $gitIgnore = "\{0}" -f $gitIgnore;
                    }
                    $gitIgnore = $gitIgnore.TrimEnd('/').Replace('/','\');
                } #end if directory
                $gitIgnore = $gitIgnore.Trim();
                $gitIgnorePath = Join-Path -Path $Path -ChildPath $gitIgnore;
                if (Test-Path -Path $gitIgnorePath) {
                    Write-Output (Get-Item -Path (Join-Path -Path $Path -ChildPath $gitIgnore));
                }
            } #end foreach gitIgnore
        } #end if

        ## Parse .gitattributes
        $gitAttributesPath = Join-Path -Path $Path -ChildPath '.gitattributes';
        if (-not (Test-Path -Path $gitAttributesPath -PathType Leaf)) {
            Write-Verbose -Message ($localized.NoGitAttributesFound -f $Path);
        }
        else {
            $gitAttributes = Get-Content -Path $gitAttributesPath -Force;
            $gitAttributes = $gitAttributes | Select-String -SimpleMatch 'export-ignore';
            foreach ($gitAttribute in $gitAttributes) {
                $gitAttribute = $gitAttribute -replace 'export-ignore', '';
                $gitAttribute = $gitAttribute -replace '/', '\';
                $gitAttribute = $gitAttribute.Trim();
                $gitAttributePath = Join-Path -Path $Path -ChildPath $gitAttribute;
                if (Test-Path -Path $gitAttributePath) {
                    Write-Output (Get-Item -Path (Join-Path -Path $Path -ChildPath $gitAttribute));
                }
            } #end foreach
        } #end if

    } #end process
} #end function
