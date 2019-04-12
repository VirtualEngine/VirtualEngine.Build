function Invoke-GitHubAssetUpload {
<#
    .SYNOPSIS
        Publishes an asset to a GitHub release.
    .DESCRIPTION
        Uses the GitHub API to upload a binary asset to the specified GitHub
        release. A GitHub API key with push authorisation is required to upload
        the asset.

        A release object from the New-GitHubRelease cmdlet can be passed
        to this cmdlet.
    .NOTES
        Ensure that the GitHub API key is sufficiently protected in any scripts.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## GitHub release object response
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Object] $Release,

        ## Github Api Key
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ApiKey,

        ## Path to .zip artifact to push as the release binary
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Path
    )
    begin {
        ## Check we have a release object
        if (-not ($Release.Upload_Url)) {
            Write-Error ('InputObject does not appear to be a GitHub API release object.');
            break;
        }
        ## Check if we have a directory
        $Path = Resolve-Path -Path $Path;
        if (Test-Path -Path $Path -PathType Container) {
            Write-Error ('Path "{0}" is not a file.' -f $Path);
            break;
        }
        else {
            $file = Get-Item -Path $Path;
        }
    }
    process {
        $authorizationHeader = '{0}:x-oauth-basic' -f $ApiKey;
        $authorizationToken = 'Basic {0}' -f [System.Convert]::ToBase64String( [System.Text.Encoding]::ASCII.GetBytes($authorizationHeader) );
        $releaseFilename = '?name={0}' -f $file.Name;
        $uploadParam = @{
            Uri = $Release.Upload_Url -replace '\{\?name\}', $releaseFilename;
            Method = 'POST';
            Headers = @{
                Authorization = $authorizationToken;
            }
            ContentType = 'application/zip';
            InFile = $Path;
        }
        $response = Invoke-WebRequest @uploadParam;
        Write-Output (ConvertFrom-Json -InputObject $response.Content);
    } #end process
} #end function
