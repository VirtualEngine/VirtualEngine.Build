$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Get-GitTag" {
    Mock Invoke-Expression { Write-Output '1.0.0' } -ParameterFilter { Command -eq 'git.exe describe --abbrev=0 --tags' }

    It "calls 'git.exe describe --abbrev=0 --tags'." {
        Get-GitTag | Should Be '1.0.0';
        Assert-MockCalled -CommandName Invoke-Expression -ParameterFilter { Command -eq 'git.exe descrive --abbrev=0 --tags' };
    }
}

Describe "Get-GitRevision" {
    Mock Invoke-Expression { Write-Output 48 } -ParameterFilter { Command -eq 'git.exe rev-list HEAD --count' }

    It "calls 'git.exe rev-list HEAD --count'." {
        Get-GitRevision | Should Be '48';
        Assert-MockCalled -CommandName Invoke-Expression -ParameterFilter { Command -eq 'git.exe rev-list HEAD --count' };
    }
}

Describe "Convert-ToVersionArray" {

    It "converts 1.2 to 1,2,0,0" {
        [String]::Join(',', (Convert-ToVersionArray -InputObject '1.2')) | Should Be ([String]::Join(',', @(1,2,0,0)));
    }

    It "converts 1.2.3 to 1,2,3,0" {
        [String]::Join(',', (Convert-ToVersionArray -InputObject '1.2.3')) | Should Be ([String]::Join(',', @(1,2,3,0)));
    }

    It "converts 1.2.3.4 to 1,2,3,4" {
        [String]::Join(',', (Convert-ToVersionArray -InputObject '1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }
    
    It "converts prefixed v1.2.3.4 to 1,2,3,4" {
        [String]::Join(',', (Convert-ToVersionArray -InputObject 'v1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }

    It "converts prefixed V1.2.3.4 to 1,2,3,4" {
        [String]::Join(',', (Convert-ToVersionArray -InputObject 'V1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }

    It "truncates 1.2.3.4.5 to 1,2,3,4" {
        [String]::Join(',', (Convert-ToVersionArray -InputObject '1.2.3.4.5' -WarningAction SilentlyContinue)) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }

    It "throws on invalid version string '1'." {
        { Convert-ToVersionArray -InputObject '1' -ErrorAction Stop } | Should Throw;
    }

    It "throws on invalid version string '1.2.a'." {
        { Convert-ToVersionArray -InputObject '1.2.a' -ErrorAction Stop } | Should Throw;
    }

    It "throws on String.Empty input" {
        { Convert-ToVersionArray -InputObject ([String]::Empty) } | Should Throw;
    }

}

Describe "Get-GitAssemblyVersionString" {

}

<#

Mock Get-Process { “filtered” } -ParameterFilter { $Name -eq "Explorer" }
 $gitCommand = 'git.exe rev-list HEAD --count';

Get-GitTag {
    <#
        .SYNOPSIS
            Returns the latest Git tag for the current branch of the Git
            repository located in the current working directory.
    #>
    <#
    [CmdletBinding()]
    param ( )

    process {
        $gitCommand = 'git.exe describe --abbrev=0 --tags';
        Write-Verbose ("Running '{0}'." -f $gitCommand);
        Invoke-Expression -Command $gitCommand;
    #>
