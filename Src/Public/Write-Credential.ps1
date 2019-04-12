function Write-Credential {
<#
    .SYNOPSIS
        Writes a locally encrypted PSCredential token to a file.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        # File path to persist the SecureString.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String] $Path,

        # Secure string to persist,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $PassThru
    )
    process {
        $Credential | Export-Clixml -Path $Path -Force;
        if ($PassThru) {
            Get-Item -Path $Path;
        }
    }
} #end function
