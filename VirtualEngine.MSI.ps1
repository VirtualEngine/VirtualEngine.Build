function Get-WindowsInstallerPackageProperty {
    <#
        .SYNOPSIS
            This cmdlet retrieves a property from one or more Windows Installer MSI database.
        .DESCRIPTION
            This function uses the WindowInstaller COM object to pull all values from the Property table from a MSI package.
        .EXAMPLE
            Get-WindowsInstallerPackageProperty -Path 'MSI_PATH' -Property ProductName
        .PARAMETER Path
            The file system path to the MSI package to query.
        .NOTES
            Adapted from http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName='Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')] [string[]] $Path,
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()] [string[]] $LiteralPath,
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('ProductCode', 'ProductVersion', 'ProductName', 'UpgradeCode')] [System.String] $Property = 'ProductCode'
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            foreach ($unresolvedPath in $Path) {
                $LiteralPath += $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($unresolvedPath);
            }
        } # end if
    } #end begin
    process {
        $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer;
        foreach ($Path in $LiteralPath) {
            Write-Verbose ('Opening MSI database "{0}".' -f $Path);
            try {
                $msiDatabase = $windowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $windowsInstaller, @("$Path", 0));
                $query = "SELECT Value FROM Property WHERE Property = '$($Property)'";
                $view = $msiDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $msiDatabase, $query);
                $view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null);
                $record = $view.GetType().InvokeMember('Fetch','InvokeMethod', $null, $view, $null);
                $value = $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, 1);
                Write-Output $value;
            } 
            catch {
                Write-Output $_.Exception.Message;
            }
        } #end foreach path
    } #end process
} #end function Get-WindowsInstallerPackageProperty
