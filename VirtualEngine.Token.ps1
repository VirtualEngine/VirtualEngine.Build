function Read-SecureString {
    <#
        .SYNOPSIS
            Reads a locally encrypted SecureString token from a file.
    #>
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param (
        # File path to SecureString to read.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [System.String] $Path
    )
    process {
        (Get-Content -Path $Path) | ConvertTo-SecureString;
    }
} #end function Read-SecureString

function Write-SecureString {
<#
    .SYNOPSIS
        Writes a locally encrypted SecureString token to a file.
#>
    [CmdletBinding()]
    param (
        # File path to persist the SecureString.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [System.String] $Path,
        # Secure string to persist,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [System.Security.SecureString] $SecureString
    )
    process {
        ConvertFrom-SecureString -SecureString $SecureString | Out-File -FilePath $Path -Force;
    }
} #end function Write-SecureString

function ConvertTo-InsecureString {
<#
    .SYNOPSIS
        Converts a SecureString to String.
    .NOTES
        USE WITH CAUTION!
#>
    [CmdletBinding()]
    [OutputType([System.Security.SecureString])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Security.SecureString] $SecureString
    )
    process {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR);
    }
} #end function ConvertTo-InsecureString
