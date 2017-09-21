Function New-NAVAzureTenantSqlDatabase {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SqlServer

    )
       
    $SelectedElasticPool = Get-NAVAzureSqlElasticPool -AzureResourceGroup $AzureResourceGroup -SqlServer $SqlServer
    if (!$SelectedElasticPool) { break }

    $newDatabaseName = Read-Host -Prompt "Type name for new database (default = Tenant-<Id>)"
    if ($newDatabaseName -eq "") { exit }

    $databaseExists = Get-AzureRmSqlDatabase -DatabaseName $newDatabaseName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -ErrorAction SilentlyContinue
    if ($databaseExists) {
        Write-Host -ForegroundColor Red "Database ${newDatabaseName} already exists!"
        $anyKey = Read-Host "Press enter to continue..."
        break
    }

    Write-Host "Starting Database Creation (will take some time)..."
    New-AzureRmSqlDatabase -DatabaseName $newDatabaseName -CollationName Icelandic_100_CS_AS -Edition Standard -ElasticPoolName $SelectedElasticPool.ElasticPoolName -ServerName $SqlServer.ServerName -ResourceGroupName $AzureResourceGroup.ResourceGroupName

    $UserName = $Credential.UserName
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))
    $Result = Get-SQLCommandResult -Server "$($SqlServer.ServerName).database.windows.net" -Database $newDatabaseName -Command "CREATE USER $($Credential.UserName) FROM LOGIN $($Credential.UserName);" -Username $UserName -Password $Password
    $Result = Get-SQLCommandResult -Server "$($SqlServer.ServerName).database.windows.net" -Database $newDatabaseName -Command "ALTER ROLE db_owner ADD MEMBER $($Credential.UserName);" -Username $UserName -Password $Password
    
}