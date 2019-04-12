function ConvertFrom-SecureString {
<#
    .SYNOPSIS
        Converts a SecureString to String.
    .NOTES
        USE WITH CAUTION!
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Security.SecureString] $SecureString
    )
    process {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR);
    }
} #end function
