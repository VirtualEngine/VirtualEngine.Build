function Write-SecureString {
<#
    .SYNOPSIS
        Writes a locally encrypted SecureString token to a file.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        # File path to persist the SecureString.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String] $Path,

        # Secure string to persist,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Security.SecureString] $SecureString,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $PassThru
    )
    process {
        ConvertFrom-SecureString -SecureString $SecureString | Out-File -FilePath $Path -Force;
        if ($PassThru) {
            Get-Item -Path $Path;
        }
    }
} #end function
