function Get-ModuleFile {
<#
.SYNOPSIS
    Gets files to be bundled with a module release.
.DESCRIPTION
    The Get-ModuleFile cmdlet gets a list of files to be included for a module
    release. It ignores the .Git folder and any file/folder specified in the .gitignore
    file if present.

    An additional array of files to be excluded can be passed in using the
    -Exclude parameter that performs pattern matching.
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        # One or more file paths to enumerate.
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')]
        [System.String] $Path = (Get-Location -PSProvider FileSystem),

        # One or more literal files paths to enumerate.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath,

        # File paths/matches to exclude. Git files are excluded by default, but if
        # -Excludes are specified, remember to add '.git*' to the exclusion list!
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [AllowEmptyCollection()]
        [System.String[]] $Exclude = @('.git*'),

        # Include hidden/system files
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        else {
            $Path = $LiteralPath;
        } # end if
        if (-not (Test-Path -Path $Path -PathType Container)) {
            throw ($localized.NotDirectoryPathError -f $Path);
        }

    } #end begin
    process {

        # Only create ignoredFiles once in the parent scope. Recursive calls will use the parent's scoped variable
        if (!$ignoredFiles) { $ignoredFiles = GetModuleExcludedFile -Path $Path; }
        foreach ($moduleFile in (Get-ChildItem -Path $Path -Force:$Force -File)) {
            Write-Verbose -Message ($localized.CheckingForExcludedFile -f $moduleFile.FullName);
            ## Check whether the file has been manually excluded
            $isExcluded = $false;
            foreach ($excludedFile in $Exclude) {
                if ($moduleFile.FullName -like $excludedFile -or $moduleFile.Name -like $excludedFile) {
                    $isExcluded = $true;
                    Write-Verbose -Message ($localized.FilePathExcluded -f $moduleFile, $excludedFile);
                }
            }
            if (-not $isExcluded) {
                Write-Output $moduleFile;
            }
        } # end foreach

        foreach ($moduleDirectory in (Get-ChildItem -Path $Path -Force:$Force -Directory)) {
            $isExcluded = $false;
            foreach ($excludedDirectory in $Exclude) {
                if ($moduleDirectory.FullName -like $excludedFile -or $moduleDirectory.Name -like $excludedDirectory) {
                    $isExcluded = $true;
                    Write-Verbose ($localized.DirectoryPathExcluded -f $moduleFile, $excludedDirectory);
                }
            }
            if (-not $isExcluded) {
                Get-ModuleFile -Path $moduleDirectory.FullName -Exclude $Exclude -Force:$force;
            }
        } # end foreach

    } #end process
} #end function
