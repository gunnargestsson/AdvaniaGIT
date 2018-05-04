function Update-NAVLicense
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$LicenseFilePath
    )   
    if (Test-Path $LicenseFilePath) {
		Write-Host "Importing NAV license ..."
    	Import-NAVServerLicense -ServerInstance $BranchSettings.instanceName -LicenseFile $LicenseFilePath -Database NavDatabase -Force
    }
}