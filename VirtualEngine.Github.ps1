function Get-GitHubProjectUri {
    <#
        .SYNOPSIS
            Resolves GitHub project Url for the Git repository in the current
            working directory.
        .DESCRIPTION
            Queries the remote origin of the Git repository in the current working
            directory and ensures that it's a repository hosted on GitHub.
    #>
    [CmdletBinding()]
    param ( )
    begin {
        if (-not (Test-Git)) {
            Write-Error 'Git does not appear to be installed or in the system path.';
        }

    } #end begin
    process {
        $origin = Get-GitRemoteOrigin;
        if ($origin -inotmatch 'https:\/\/github.com\/.+\.git$') {
            Write-Error ('Remote origin "{0}" does not appear to be a Github repository.' -f $origin);
        }
        else {
            Write-Output ($origin.TrimEnd('git').TrimEnd('.'));
        }
    } #end process
} #end function Get-GithubProjectUri


function New-GitHubRelease {
    <#
        .SYNOPSIS
            Creates a new GitHub release.
        .DESCRIPTION
            Uses the GitHub API to create a new release. A GitHub API key with push
            authorisation is required to create the release.
        .NOTES
            Ensure that the GitHub API key is sufficiently protected in any scripts.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## Release version, i.e. v1.2.3 or 1.2.3
        [Parameter(ValueFromPipelineByPropertyName = $true)] [ValidateNotNullOrEmpty()] [System.String] $Version = (Get-GitVersionString),
        ## Github repository owner
        [Parameter(Mandatory = $true)] [System.String] [Alias('Username')] $Owner,
        ## Github repository name
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [System.String] $Repository,
        ## Github Api Key
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [System.String] $ApiKey,
        # Set to mark the release as draft (not visible to users)
        [Parameter(ValueFromPipelineByPropertyName = $true)] [Switch] $Draft,
        # Set to mark as a prerelease/beta version
        [Parameter(ValueFromPipelineByPropertyName = $true)] [Switch] $Prerelease,
        # Release note
        [Parameter(ValueFromPipelineByPropertyName = $true)] [ValidateNotNull()] [System.String] $ReleaseNote = ''
    )
    begin {
        if ($Version -notlike 'v*') {
            $Version = 'v{0}' -f $Version;
        }
        $authorizationHeader = '{0}:x-oauth-basic' -f $ApiKey;
        $authorizationToken = 'Basic {0}' -f [System.Convert]::ToBase64String( [System.Text.Encoding]::ASCII.GetBytes($authorizationHeader) );
    }
    process {
        $releaseBody = @{
            tag_name = $version;
            target_commitish = 'master';
            name = $version;
            body = $releaseNotes;
            draft = [System.Boolean] $Draft;
            prerelease = [System.Boolean] $prerelease;
        }

        $releaseParam = @{
            Uri = 'https://api.github.com/repos/{0}/{1}/releases' -f $Owner, $Repository;
            Method = 'POST';
            Headers = @{
                Authorization = $authorizationToken;
            }
            ContentType = 'application/json';
            Body = (ConvertTo-Json $releaseBody -Compress);
        }
        $response = Invoke-WebRequest @releaseParam;
        Write-Output (ConvertFrom-Json -InputObject $response.Content);
    } #end process
} #end function New-GithubRelease

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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] [System.Object] $Release,
        ## Github Api Key
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [System.String] $ApiKey,
        ## Path to .zip artifact to push as the release binary
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)] [System.String] $Path
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
} #end function Invoke-GitHubAssetUpload
