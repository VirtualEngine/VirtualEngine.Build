function Set-ScriptSignature {
<#
    .SYNOPSIS
        Signs a script file.
    .DESCRIPTION
        The Set-ScriptSignature cmdlet signs a PowerShell script file using the specified certificate thumbprint.
    .EXAMPLE
        Set-ScriptSignature -Path .\Example.psm1 -Thumbprint D10BB31E5CE3048A7D4DA0A4DD681F05A85504D3

        This example signs the 'Example.psm1' file in the current path using the certificate.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Path')]
    [OutputType([System.Management.Automation.Signature])]
    param (
        # One or more files/paths of the files to sign.
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')]
        [System.String[]] $Path = (Get-Location -PSProvider FileSystem),

        # One or more literal files/paths of the files to sign.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath,

        # Thumbprint of the certificate to use.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Thumbprint,

        # Signing timestamp server URI
        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $TimeStampServer = 'http://timestamp.verisign.com/scripts/timestamp.dll'
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            for ($i = 0; $i -lt $Path.Length; $i++) {
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        }
        else {
            $Path = $LiteralPath;
        } # end if
        $codeSigningCert = Get-ChildItem -Path Cert:\ -CodeSigningCert -Recurse | Where-Object Thumbprint -eq $Thumbprint;
        if (!$codeSigningCert) {
            throw ($localized.InvalidCertificateThumbprintError -f $Thumbprint);
        }

    } # end begin
    process {

        foreach ($resolvedPath in $Path) {
            if (Test-Path -Path $resolvedPath -PathType Leaf) {
                $signResult = Set-AuthenticodeSignature -Certificate $codeSigningCert -TimestampServer $TimeStampServer -FilePath $Path;
                if ($signResult.Status -ne 'Valid') {
                    Write-Error ($localized.SigningFileError -f $Path);
                }
                Write-Output $signResult;
            }
            else {
                Write-Warning ($localized.FileNotFoundOrDirectoryWarning -f $resolvedPath);
            }
        } # end foreach

    } # end process
} #end function
