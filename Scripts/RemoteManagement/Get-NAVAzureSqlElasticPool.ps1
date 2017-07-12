Function Get-NAVAzureSqlElasticPool {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SqlServer
    )
    $elasticPools = Get-AzureRmSqlElasticPool -ResourceGroupName $AzureResourceGroup.ResourceGroupName -ServerName $SqlServer.ServerName
    if ($elasticPools.Count -eq 1) { return $elasticPools | Select-Object -First 1 }
    $elasticPoolNo = 1
    $menuItems = @()
    foreach ($elasticPool in $elasticPools) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $elasticPoolNo
        $menuItem = Combine-Settings $menuItem $elasticPool
        $menuItems += $menuItem
        $elasticPoolNo ++
    }

    do {
        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, ElasticPoolName, Location, Tags -AutoSize | Out-Host
        $input = Read-Host "Please select elastic pool number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedElasticPool = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedElasticPool) { return $selectedElasticPool }
            }
        }
    }
    until ($input -ieq '0')
}