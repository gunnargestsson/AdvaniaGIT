Function New-AzureSqlDatabase {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SqlServer

    )
    
    $SelectedBacpac = Get-LocalBacPacFilePath
    if (!(Test-Path -Path $SelectedBacpac.FullName)) { break }
    
    $SelectedElasticPool = Get-AzureSqlElasticPool -AzureResourceGroup $AzureResourceGroup -SqlServer $SqlServer
    if (!$SelectedElasticPool) { break }

    $newDatabaseName = Read-Host -Prompt "Type name for new database (default = $($SelectedBacpac.BaseName))"
    if ($newDatabaseName -eq "") { $newDatabaseName = $SelectedBacpac.BaseName }
    $SqlPackagePath = Get-SqlPackagePath 

    $UserName = $Credential.UserName
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))

    Write-Host "Starting Database Import..."
    $Arguments = @("/action:Import /sourcefile:""$($SelectedBacpac.FullName)"" /targetservername:$($SqlServer.ServerName).database.windows.net /targetuser:${UserName} /targetpassword:${Password} /targetdatabasename:${newDatabaseName}")
    Start-Process -FilePath $SqlPackagePath -ArgumentList @Arguments -NoNewWindow -Wait
    Write-Host "Add database to Elastic Pool..."
    Set-AzureRmSqlDatabase -DatabaseName $newDatabaseName -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName -ElasticPoolName $SelectedElasticPool.ElasticPoolName 
}