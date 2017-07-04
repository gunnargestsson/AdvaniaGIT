Function Remove-AzureSqlDatabase {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SqlServer,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseName
    )
    
    $databaseExists = Get-AzureRmSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -ErrorAction SilentlyContinue
    if ($databaseExists) {
        $confirmDatabase = Read-Host -Prompt "Retype the database name to confirm removal"
        if ($DatabaseName -ieq $confirmDatabase) {
            $removedDatabase = Remove-AzureRmSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -Force 
        }
    } else {
        Write-Host -ForegroundColor Red "Database ${DatabaseName} not found on server $($SqlServer.ServerName)!"
        $anyKey = Read-Host "Press enter to continue..."
        break
    }
}