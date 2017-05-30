function Initialize-NAVTestCompany
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$CompanyName,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$DefaultRegistrationNo = '5902697199'
    )   

    Sync-NAVTenant -ServerInstance $BranchSettings.instanceName -Tenant default -Mode Sync -Force 
    Start-NAVDataUpgrade -ServerInstance $BranchSettings.instanceName -Tenant default -Language is-IS -ContinueOnError -FunctionExecutionMode Parallel -Force
    Get-NAVDataUpgrade -ServerInstance $BranchSettings.instanceName -Tenant default -Progress

    $command = "SELECT [Registration No_] FROM [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'Company Information')]"
    $RegistrationNo = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
    if ($RegistrationNo.'Registration No_' -eq "") {
      Set-NAVCompanyInfoRegistrationNo -BranchSettings $BranchSettings -CompanyName $CompanyName -RegistrationNo $DefaultRegistrationNo
    }
    return $RegistrationNo.'Registration No_'
}