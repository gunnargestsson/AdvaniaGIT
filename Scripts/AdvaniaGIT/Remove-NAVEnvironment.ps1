function Remove-NAVEnvironment
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $webServerInstance = Get-NAVWebServerInstance -WebServerInstance $BranchSettings.instanceName 
    if ($webServerInstance) {
        Write-Host "Removing Web Server Instance..."
        if ($webServerInstance.'Configuration File'.contains('web.config')) {
            Remove-NAVWebServerInstance -WebServerInstance $BranchSettings.instanceName -Force
        } else {
            Remove-NAVWebServerInstance -WebServerInstance $BranchSettings.instanceName
        }        
    }
    Write-Host "Removing Server Instance..."
    Get-NAVServerInstance -ServerInstance $BranchSettings.instanceName | Remove-NAVServerInstance -Force
    if ($BranchSettings.databaseName -ne "") {
        Write-Host "Removing Database..."
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database master -Command "ALTER DATABASE [$($BranchSettings.DatabaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$($BranchSettings.databaseName)]" -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword | Out-Null
    }
    $BlankBranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId
}
