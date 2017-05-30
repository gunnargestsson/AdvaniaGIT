function Set-NAVCompanyInfoRegistrationNo
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$CompanyName,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$RegistrationNo
    )   

    $command = "UPDATE [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'Company Information')] SET [Registration No_] = '$RegistrationNo' "
    Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null
}