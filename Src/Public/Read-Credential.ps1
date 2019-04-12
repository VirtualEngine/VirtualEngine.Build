function Read-Credential {
<#
    .SYNOPSIS
        Reads a locally encrypted credential token from a file.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCredential])]
    param (
        # File path to SecureString to read.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String] $Path
    )
    process {
        Import-Clixml -Path $Path;
    }
} #end function
