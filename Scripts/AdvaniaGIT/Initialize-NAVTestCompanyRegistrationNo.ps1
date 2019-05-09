function Initialize-NAVTestCompanyRegistrationNo
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$CompanyName,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$DefaultRegistrationNo = '5902697199'
    )   

    $command = "SELECT [Registration No_] FROM [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'Company Information')]"
    $RegistrationNo = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword
    if ($RegistrationNo.'Registration No_' -eq "") {
      Set-NAVCompanyInfoRegistrationNo -BranchSettings $BranchSettings -CompanyName $CompanyName -RegistrationNo $DefaultRegistrationNo
    }
    return $RegistrationNo.'Registration No_'
}