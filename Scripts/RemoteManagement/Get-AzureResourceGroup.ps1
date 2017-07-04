Function Get-AzureResourceGroup {
    $resourceGroups = Get-AzureRmResourceGroup 
    if ($resourceGroups.Count -eq 1) { return $resourceGroups | Select-Object -First 1 }
    $resourceGroupNo = 1
    $menuItems = @()
    foreach ($resourceGroup in $resourceGroups) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $resourceGroupNo
        $menuItem = Combine-Settings $menuItem $resourceGroup
        $menuItems += $menuItem
        $resourceGroupNo ++
    }

    do {
        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }        
        $menuItems | Format-Table -Property No, Location, ResourceGroupName, Tags -AutoSize | Out-Host
        $input = Read-Host "Please select resource group number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedResourceGroup = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedResourceGroup) { return $selectedResourceGroup }
            }
        }
    }
    until ($input -ieq '0')
}
