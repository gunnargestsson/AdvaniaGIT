Function Remove-NAVDatabaseServicePasswords
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    $command = "SELECT [invalididentifierchars] FROM [dbo].[`$ndo`$dbproperty]"
    $invalidChars = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
    $command = "SELECT Name FROM [dbo].[Company] "
    $companies = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
    foreach ($company in $companies.Name) {
        $tableName = "${company}`$Service Password"
        For ($i=0; $i -lt $invalidChars.invalididentifierchars.Length; $i++) { 
            $tableName = $tableName.Replace($invalidChars.invalididentifierchars.SubString($i,1),"_")
        }
        $command = "DELETE FROM [dbo].[${tableName}]"
        $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
    }
    Write-Host "All Service Passwords from $($BranchSettings.databaseName) have been removed..."
}



        