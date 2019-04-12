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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## Release version, i.e. v1.2.3 or 1.2.3
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Version = (Get-GitVersionString),

        ## Github repository owner
        [Parameter(Mandatory)]
        [System.String] [Alias('Username')] $Owner,

        ## Github repository name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Repository,

        ## Github Api Key
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ApiKey,

        # Set to mark the release as draft (not visible to users)
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Draft,

        # Set to mark as a prerelease/beta version
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Prerelease,

        # Release note
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()]
        [System.String] $ReleaseNote = ''
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
} #end function
