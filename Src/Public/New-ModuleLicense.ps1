function New-ModuleLicense {
<#
    .SYNOPSIS
        Creates a new license file.
    .DESCRIPTION
        Creates a new Apache, GPLv2 or GPLv3 or by default, a MIT license file.
    .NOTES
        The -Project parameter is only applicable to the GPLv2 and GPLv3 licenses.
    .EXAMPLE
        New-ModuleLicense -Path .\LICENSE -FullName 'Virtual Engine Limited'

        Creates a new MIT 'LICENSE' file in the current directory stamped with the
        current year and licensed to 'Virtual Engine Limited'.

    .EXAMPLE
        New-ModuleLicense -Path .\LICENSE.txt -FullName 'Virtual Engine Limited' -Project 'Virtual Engine Build' -LicenseType GPLv3

        Creates a new GPL v3 'LICENSE.txt' file in the current directory stamped with the
        current year, licensed to 'Virtual Engine Limited' with a project name of
        'Virtual Engine Build'.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.FileInfo])]
    param (
        # File path to the license file to create.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath')]
        [System.String] $Path,

        # Literal file path to the license file to create.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String] $LiteralPath,

        # License type.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateSet('Apache','MIT','GPLv2','GPLv3')]
        [System.String] $LicenseType = 'MIT',

        # Licensee full name.
        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $FullName,

        # Project/product name.
        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String] $Project = '',

        # Do not overwrite an existing file.
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $NoClobber
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $LiteralPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }
        if (Test-Path -LiteralPath $LiteralPath -PathType Container) {
            throw ($localized.NotFilePathError -f $LiteralPath);
        }

    } # end begin
    process {

        $license = $licenses[$LicenseType];
        $license = $license -replace '{year}', (Get-Date).Year;
        $license = $license -replace '{fullname}', $FullName;
        $license = $license -replace '{project}', $Project;
        if ($NoClobber -and (Test-Path -LiteralPath $LiteralPath)) {
            Write-Error ($localized.FileExistsError -f $LiteralPath);
        }
        else {
            Set-Content -LiteralPath $LiteralPath -Value $license -Encoding Ascii -Force;
            Write-Output (Get-Item -LiteralPath $LiteralPath);
        }

    } # end process
} #end function
