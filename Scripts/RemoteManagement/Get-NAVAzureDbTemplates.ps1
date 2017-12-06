Function Get-NAVAzureDbTemplates {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$AzureResourceGroup,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$ContainerName
    )

    $RemoteConfig = Get-NAVRemoteConfig
    $StorageAccountAccess = Get-NAVPasswordStateUser -PasswordId $RemoteConfig.DatabaseTemplateStoragePasswordID
    $storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $AzureResourceGroup.ResourceGroupName -Name $StorageAccountAccess.UserName
    $storageAccountContext = New-AzureStorageContext -StorageAccountName $StorageAccountAccess.UserName -StorageAccountKey $StorageAccountAccess.Password
    $storageContainers = Get-AzureStorageContainer -Context $storageAccountContext 
    $storageContainerNo = 1
    $menuItems = @()
    foreach ($storageContainer in $storageContainers) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $storageContainerNo
        $menuItem = Combine-Settings $menuItem $storageContainer
        $menuItem | Add-Member -MemberType NoteProperty -Name Blob -Value (Get-AzureStorageBlob -Container $storageContainer.Name -Context $storageAccountContext)
        $menuItem | Add-Member -MemberType NoteProperty -Name Access -Value $StorageAccountAccess
        $menuItems += $menuItem
        $storageContainerNo ++
    }

    if ($ContainerName -ne $null) {
        return $menuItems | Where-Object -Property Name -EQ $ContainerName
    }

    do {
        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Name -AutoSize | Out-Host
        $input = Read-Host "Please select storage container number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedstorageContainer = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedstorageContainer) { return $selectedstorageContainer }
            }
        }
    }
    until ($input -ieq '0')
}