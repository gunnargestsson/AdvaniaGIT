Function New-NAVKontoTenantSqlDatabase {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DatabaseName
    )

    $RemoteConfig = Get-NAVRemoteConfig

    $DBAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.DBUserPasswordID
    if ($DBAdmin.UserName -gt "" -and $DBAdmin.Password -gt "") {
        $DbCredential = New-Object System.Management.Automation.PSCredential($DBAdmin.UserName, (ConvertTo-SecureString $DBAdmin.Password -AsPlainText -Force))
    } else {
        $DBCredential = Get-Credential -Message "Remote Login to Azure SQL" -ErrorAction Stop
        $DBAdmin.UserName = $Credential.UserName
        $DBAdmin.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))
    }    

    if (!$DbCredential.UserName -or !$DbCredential.Password) {
        Write-Host -ForegroundColor Red "Credentials required!"
        break
    }

    $VMAdmin = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.VMUserPasswordID
    if ($VMAdmin.UserName -gt "" -and $VMAdmin.Password -gt "") {
        $Credential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))
    } else {
        $Credential = Get-Credential -Message "Admin Access to Azure SQL" -ErrorAction Stop    
    }

    if (!$Credential.UserName -or !$Credential.Password) {
        Write-Host -ForegroundColor Red "Credentials required!"
        break
    }


    if ($DBAdmin.GenericField1 -gt "") {
        $databaseServer = Get-AzureRmResourceGroup | Get-AzureRmSqlServer | Where-Object -Property ServerName -ieq $DBAdmin.GenericField1.Split(".").GetValue(0)
        $resourceGroup = Get-AzureRmResourceGroup -Name $databaseServer.ResourceGroupName
    } else {
        Remove-Variable resourceGroup -ErrorAction SilentlyContinue
        Remove-Variable databaseServer -ErrorAction SilentlyContinue
    }

    #Select Azure Resource Group
    if (!$resourceGroup) { $resourceGroup = Get-NAVAzureResourceGroup }
    if (!$resourceGroup) {
        Write-Host -ForegroundColor Red "Azure Resource Group required!"
        break
    }

    # Select Azure Sql Database Server
    if (!$databaseServer) { $databaseServer = Get-NAVAzureSqlServer -AzureResourceGroup $resourceGroup }
    if (!$databaseServer) {
        Write-Host -ForegroundColor Red "Azure Sql Database Server required!"
        break
    }

       
    $SelectedElasticPool = Get-NAVAzureSqlElasticPool -AzureResourceGroup $resourceGroup -SqlServer $databaseServer
    if (!$SelectedElasticPool) { break }
    
    $databaseExists = Get-AzureRmSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $resourceGroup.ResourceGroupName -ServerName $databaseServer.ServerName -ErrorAction SilentlyContinue
    if ($databaseExists) {
        Write-Host -ForegroundColor Red "Database ${newDatabaseName} already exists!"
        $anyKey = Read-Host "Press enter to continue..."
        break
    }

    $Template = Get-NAVAzureDbTemplates -AzureResourceGroup $resourceGroup -ContainerName $Provider.TenantTemplateContainer
    $UserName = $Credential.UserName
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))

    
    if ($Template) {
        Write-Host "Starting Database Restore from $($Template.Blob[0].Name) (will take some time)..."
        $Database = New-AzureRmSqlDatabaseImport -DatabaseName $DatabaseName -ServerName $databaseServer.ServerName -ResourceGroupName $resourceGroup.ResourceGroupName -StorageKeyType "StorageAccessKey" -StorageKey $Template.Access.Password -StorageUri "$($Template.Context.BlobEndPoint)$($Template.Name)/$($Template.Blob[0].Name)" -Edition Standard -ServiceObjectiveName S1 -DatabaseMaxSizeBytes 5000000 -AdministratorLogin $Credential.UserName -AdministratorLoginPassword $Credential.Password -AuthenticationType Sql
        do {        
            Start-Sleep -Seconds 10
            Write-Host "$((Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $Database.OperationStatusLink).Status) - $((Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $Database.OperationStatusLink).StatusMessage)"
        } 
        until ((Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $Database.OperationStatusLink).Status -ieq "Succeeded")
        $Pool = Set-AzureRmSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $resourceGroup.ResourceGroupName -ServerName $databaseServer.ServerName -ElasticPoolName $SelectedElasticPool.ElasticPoolName 
    } else {
        Write-Host "Starting Database Creation (will take some time)..."
        $Database = New-AzureRmSqlDatabase -DatabaseName $DatabaseName -CollationName Icelandic_100_CS_AS -Edition Standard -ElasticPoolName $SelectedElasticPool.ElasticPoolName -ServerName $databaseServer.ServerName -ResourceGroupName $resourceGroup.ResourceGroupName
    }

    try {
        $Result = Get-SQLCommandResult -Server "$($databaseServer.ServerName).database.windows.net" -Database $DatabaseName -Command "CREATE USER $($DbCredential.UserName) FROM LOGIN $($DbCredential.UserName);" -Username $UserName -Password $Password
        $Result = Get-SQLCommandResult -Server "$($databaseServer.ServerName).database.windows.net" -Database $DatabaseName -Command "ALTER ROLE db_owner ADD MEMBER $($DbCredential.UserName);" -Username $UserName -Password $Password
    } catch {
        Write-Host "SQL Service User configured..."
    }
    $Database = New-NAVDatabaseObject -DatabaseName $DatabaseName -DatabaseServerName "$($databaseServer.ServerName).database.windows.net" -DatabaseUserName $UserName -DatabasePassword $Password 
    return $DataBase
}