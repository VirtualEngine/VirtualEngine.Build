function Read-SecureString {
<#
    .SYNOPSIS
        Reads a locally encrypted SecureString token from a file.
#>
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param (
        # File path to SecureString to read.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String] $Path
    )
    process {
        (Get-Content -Path $Path) | ConvertTo-SecureString;
    }
} #end function
