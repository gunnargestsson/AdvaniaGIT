Function Load-NAVAzureSqlDatabaseMenu {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SqlServer
    )
    
    $databaseNo = 1
    Write-Verbose "Connect to $($SqlServer.ServerName)..."
    $databases = Get-AzureRmSqlDatabase -ServerName $SqlServer.ServerName -ResourceGroupName $AzureResourceGroup.ResourceGroupName | Where-Object -Property DatabaseName -ine master | Sort-Object -Property DatabaseName 
    foreach ($database in $databases) {
        $database | Add-Member -MemberType NoteProperty -Name No -Value $databaseNo
        $databaseNo ++
    }
    return $databases       
}