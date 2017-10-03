Function New-NAVAzureTenantSqlDatabase {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$DBCredential,
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

    $Template = Get-NAVAzureDbTemplates -AzureResourceGroup $AzureResourceGroup 
    $UserName = $Credential.UserName
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))

    Write-Host "Starting Database Creation (will take some time)..."
    if ($Template) {
        $Database = New-AzureRmSqlDatabaseImport -DatabaseName $newDatabaseName -ServerName $SqlServer.ServerName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -StorageKeyType "StorageAccessKey" -StorageKey $Template.Access.Password -StorageUri "$($Template.Context.BlobEndPoint)$($Template.Name)/$($Template.Blob[0].Name)" -Edition Standard -ServiceObjectiveName S1 -DatabaseMaxSizeBytes 5000000 -AdministratorLogin $Credential.UserName -AdministratorLoginPassword $Credential.Password -AuthenticationType Sql
        do {        
            Start-Sleep -Seconds 30
            $databaseCreated = Get-AzureRmSqlDatabase -DatabaseName $newDatabaseName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -ErrorAction SilentlyContinue
        } 
        until ($databaseCreated -ne $null)
        $Pool = Set-AzureRmSqlDatabase -DatabaseName $newDatabaseName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -ElasticPoolName $SelectedElasticPool.ElasticPoolName 
    } else {
        $Database = New-AzureRmSqlDatabase -DatabaseName $newDatabaseName -CollationName Icelandic_100_CS_AS -Edition Standard -ElasticPoolName $SelectedElasticPool.ElasticPoolName -ServerName $SqlServer.ServerName -ResourceGroupName $AzureResourceGroup.ResourceGroupName
    }

    $Result = Get-SQLCommandResult -Server "$($SqlServer.ServerName).database.windows.net" -Database $newDatabaseName -Command "CREATE USER $($DbCredential.UserName) FROM LOGIN $($DbCredential.UserName);" -Username $UserName -Password $Password
    $Result = Get-SQLCommandResult -Server "$($SqlServer.ServerName).database.windows.net" -Database $newDatabaseName -Command "ALTER ROLE db_owner ADD MEMBER $($DbCredential.UserName);" -Username $UserName -Password $Password
    
}