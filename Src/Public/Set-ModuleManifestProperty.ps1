function Set-ModuleManifestProperty {
<#
    .SYNOPSIS
        Overwrites an existing Powershell module manifest property.
    .NOTES
        This cmdlet will not create any missing property.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Path to module manifest file
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        # Module version number
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        # Module manifest root module
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $RootModule,

        # Module GUID
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Guid] $Guid,

        # Module company name
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $CompanyName,

        # Module author
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
            [System.String] $Author,

        # Copyright notice
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Copyright,

        # Module description
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Description,

        # Powershell version required
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $PowerShellVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $PassThru
    )
    begin {

        if (Test-Path -Path $Path -PathType Container) {
            Write-Error ($localized.NotFilePathError  -f $Path);
            break;
        }

    } #end begin
    process {

        (Get-Content -Path $Path) | ForEach-Object {
            if ($Version) { $PSItem = $PSItem -replace 'ModuleVersion\s*=\s*["|''].*["|'']', "ModuleVersion = '$Version'"; }
            if ($RootModule) { $PSItem = $PSItem -replace 'RootModule\s*=\s*["|''].*["|'']', "RootModule = '$RootModule'"; }
            if ($Guid) { $PSItem = $PSItem -replace 'GUID\s*=\s*["|''].*["|'']', "GUID = '$($Guid.ToString())'"; }
            if ($Author) { $PSItem = $PSItem -replace 'Author\s*=\s*["|''].*["|'']', "Author = '$Author'"; }
            if ($CompanyName) { $PSItem = $PSItem -replace 'CompanyName\s*=\s*["|''].*["|'']', "CompanyName = '$CompanyName'"; }
            if ($Description) { $PSItem = $PSItem -replace 'Description\s*=\s*["|''].*["|'']', "RootModule = '$Description'"; }
            if ($PowerShellVersion) { $PSItem = $PSItem -replace 'PowerShellVersion\s*=\s*["|''].*["|'']', "PowerShellVersion = '$PowerShellVersion'"; }
            $PSItem;
        } | Set-Content -Path $Path -Encoding UTF8 -PassThru:$PassThru;

    } #end process
} #end function
