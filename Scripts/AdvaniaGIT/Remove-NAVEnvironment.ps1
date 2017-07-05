function Remove-NAVEnvironment
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    Write-Host "Removing Web Server Instance..."
    Get-NAVWebServerInstance -WebServerInstance $BranchSettings.instanceName | Remove-NAVWebServerInstance  -Force
    Write-Host "Removing Server Instance..."
    Get-NAVServerInstance -ServerInstance $BranchSettings.instanceName | Remove-NAVServerInstance -Force
    if ($BranchSettings.databaseName -ne "") {
        Write-Host "Removing Database..."
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database master -Command "ALTER DATABASE [$($BranchSettings.DatabaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$($BranchSettings.databaseName)]" | Out-Null
    }
    $BlankBranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId
}
