function New-ChocolateyInstallPackage {
    <#
        .SYNOPSIS
            Creates a new ChocolateyInstall and ChocolateyUninstall file MSI or EXE installation.
        .DESCRIPTION
            This cmdlet copies ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files to the destination
            path specified for MSI or unattended executable installation.
        .NOTES
            For MSI deployments, the uninstallation parameters need to be specified that prepent the
            /X parameter, for example '{ba79f56e-66e1-4ff6-bef5-98d22869dbd3} /qn /norestart'.

            For EXE deployments, the uninstallation file path must point to a locally installed file
            that performs the unattended installation.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'MSI')]
    param (
        ## Destination directory for the ChocolateyInstall.ps1 and ChocolateyUninstall.ps1 files.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Path,
        ## Chocolatey package name, i.e. VirtualEngine.Build
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $PackageName,
        ## Package URL download link.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Uri,
        ## Installer silent installation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $Arguments,
        ## Valid installer exit codes.
        [Parameter(ParameterSetName = 'MSI')]
        [Parameter(ParameterSetName = 'EXE')]
        [System.Int32[]] $ValidInstallExitCode = @(0,3010),
        ## Valid uninstaller exit codes.
        [Parameter(ParameterSetName = 'MSI')]
        [Parameter(ParameterSetName = 'EXE')]
        [System.Int32[]] $ValidUninstallExitCode = @(0,3010),
        ## Windows Installer product name for uninstallation
        [Parameter(Mandatory = $true, ParameterSetName = 'MSI')]
        [System.String] $ProductName,
        ## Installer silent uninstallation arguments.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')]
        [System.String] $UninstallArguments,
        ## Installer is an EXE file.
        [Parameter(ParameterSetName = 'EXE')] [Switch] $EXE,
        ## File path to the native EXE uninstaller.
        [Parameter(Mandatory = $true, ParameterSetName = 'EXE')] [System.String] $UninstallPath
    )
    begin {
        if (-not (TestChocolateyInstallPath -Path $Path)) { break; }
        if ($PSCmdlet.ParameterSetName -eq 'EXE') { $fileType = 'EXE'; } else { $fileType = 'MSI'; }
        Write-Verbose ('Using parameter set name "{0}".' -f $PSCmdlet.ParameterSetName);
    }
    process {
        # Copy files to the destination path, replacing tokens on the way.
        $chocolateyInstall -replace '\{packagename\}', $PackageName -replace '\{downloaduri\}', $Uri -replace '\{installertype\}', $fileType -replace '\{arguments\}', $Arguments -replace '\{exitcodes\}', ([System.String]::Join(',', $ValidInstallExitCode)) |
            Set-Content -Path "$Path\ChocolateyInstall.ps1" -Encoding UTF8;
        if ($PSCmdlet.ParameterSetName -eq 'EXE') {
            $chocolateyUninstallExe -replace '\{packagename\}', $PackageName -replace '\{arguments\}', $UninstallArguments -replace '\{uninstallfile\}', $UninstallPath -replace '\{exitcodes\}', ([System.String]::Join(',', $ValidUninstallExitCode)) |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
        else {
            $chocolateyUninstallMsi -replace '\{packagename\}', $PackageName -replace '\{productname\}', $ProductName -replace '\{exitcodes\}', ([System.String]::Join(',', $ValidUninstallExitCode)) |
                Set-Content -Path "$Path\ChocolateyUninstall.ps1" -Encoding UTF8;
        }
     } #end process
} #end function
