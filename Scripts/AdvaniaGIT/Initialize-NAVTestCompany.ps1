function Initialize-NAVTestCompany
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [Switch]$RestartService
    )   

    if ($RestartService) {
        Write-Host "Restarting $($BranchSettings.instanceName) to start tests on clean service tier..."
        Set-NAVServerInstance -ServerInstance $BranchSettings.instanceName -Restart 
        Sync-NAVTenant -ServerInstance $BranchSettings.instanceName -Tenant default -Mode Sync -Force 
    }
    Write-Host "Executing upgrade codeunits for version $([int]$SetupParameters.navVersion.Split(".")[0])..."
    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 11) {
        Start-NAVDataUpgrade -ServerInstance $BranchSettings.instanceName -Tenant default -Language is-IS -ContinueOnError -FunctionExecutionMode Parallel -Force -SkipAppVersionCheck
    } else {
        Start-NAVDataUpgrade -ServerInstance $BranchSettings.instanceName -Tenant default -Language is-IS -ContinueOnError -FunctionExecutionMode Parallel -Force
    }
    Get-NAVDataUpgrade -ServerInstance $BranchSettings.instanceName -Tenant default -Progress    
}