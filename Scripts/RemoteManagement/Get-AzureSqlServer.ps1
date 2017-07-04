Function Get-AzureSqlServer {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup
    )
    $databaseServers = Get-AzureRmSqlServer -ResourceGroupName $AzureResourceGroup.ResourceGroupName
    if ($databaseServers.Count -eq 1) { return $databaseServers | Select-Object -First 1 }
    $databaseServerNo = 1
    $menuItems = @()
    foreach ($databaseServer in $databaseServers) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $databaseServerNo
        $menuItem = Combine-Settings $menuItem $databaseServer
        $menuItems += $menuItem
        $databaseServerNo ++
    }

    do {
        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, ServerName, Location, Tags -AutoSize | Out-Host
        $input = Read-Host "Please select database server number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedDatabaseServer = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedDatabaseServer) { return $selectedDatabaseServer }
            }
        }
    }
    until ($input -ieq '0')
}