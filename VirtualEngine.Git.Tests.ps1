$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Get-GitTag" {
    Mock Invoke-Expression { Write-Output '1.0.0' } -ParameterFilter { $Command -eq 'git.exe describe --abbrev=0 --tags' }

    It "calls 'git.exe describe --abbrev=0 --tags'." {
        Get-GitTag | Should Be '1.0.0';
        Assert-MockCalled -CommandName Invoke-Expression -ParameterFilter { $Command -eq 'git.exe describe --abbrev=0 --tags' };
    }
}

Describe "Get-GitRevision" {
    Mock Invoke-Expression { Write-Output 48 } -ParameterFilter { $Command -eq 'git.exe rev-list HEAD --count' }

    It "calls 'git.exe rev-list HEAD --count'." {
        Get-GitRevision | Should Be '48';
        Assert-MockCalled -CommandName Invoke-Expression -ParameterFilter { $Command -eq 'git.exe rev-list HEAD --count' };
    }
}

Describe "ConvertToAssemblyVersionArray" {

    It "converts 1.2 to 1,2,0,0" {
        [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2')) | Should Be ([String]::Join(',', @(1,2,0,0)));
    }

    It "converts 1.2.3 to 1,2,3,0" {
        [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2.3')) | Should Be ([String]::Join(',', @(1,2,3,0)));
    }

    It "converts 1.2.3.4 to 1,2,3,4" {
        [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }
    
    It "converts prefixed v1.2.3.4 to 1,2,3,4" {
        [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject 'v1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }

    It "converts prefixed V1.2.3.4 to 1,2,3,4" {
        [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject 'V1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }

    It "truncates 1.2.3.4.5 to 1,2,3,4" {
        [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject '1.2.3.4.5' -WarningAction SilentlyContinue)) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }

    It "truncates prefixed v1.2.3.4.5 to 1,2,3,4" {
        [String]::Join(',', (ConvertToAssemblyVersionArray -InputObject 'V1.2.3.4')) | Should Be ([String]::Join(',', @(1,2,3,4)));
    }

    It "throws on invalid version string '1'." {
        { ConvertToAssemblyVersionArray -InputObject '1' -ErrorAction Stop } | Should Throw;
    }

    It "throws on invalid version string '1.2.a'." {
        { ConvertToAssemblyVersionArray -InputObject '1.2.a' -ErrorAction Stop } | Should Throw;
    }

    It "throws on String.Empty input" {
        { ConvertToAssemblyVersionArray -InputObject ([String]::Empty) } | Should Throw;
    }
}

Describe "Get-GitVersionString" {

    It "outputs 1.2.0.48" {
        Mock Get-GitTag { Write-Output '1.2' };
        Mock Get-GitRevision { Write-Output 48 };
        Get-GitVersionString | Should BeExactly '1.2.0.48';
    }

    It "outputs 1.0.3.97" {
        Mock Get-GitTag { Write-Output 'v1.0.3' };
        Mock Get-GitRevision { Write-Output 97 };
        Get-GitVersionString | Should BeExactly '1.0.3.97';
    }
}
