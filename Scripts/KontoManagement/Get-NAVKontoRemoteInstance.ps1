Function Get-NAVKontoRemoteInstance {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$InstanceName
    )

    $RemoteConfig = Get-NAVRemoteConfig
    $Credential = Get-NAVKontoRemoteCredentials
    
    if (!$Credential.UserName -or !$Credential.Password) {
        Write-Host -ForegroundColor Red "Credentials required!"
        break
    }

    $NavInstances = Load-NAVRemoteInstanceMenu -Credential $Credential -RemoteConfig $RemoteConfig -DeploymentName $DeploymentName 
    if ($InstanceName -ne $null) {
        return $NavInstances | Where-Object -Property ServerInstance -eq $InstanceName
    }
    if ($NavInstances.Count -eq 1) { return $NavInstances | Select-Object -First 1 }
    $NavInstanceNo = 1
    $menuItems = @()
    foreach ($NavInstance in $NavInstances) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $NavInstanceNo
        $menuItem = Combine-Settings $menuItem $NavInstance
        $menuItems += $menuItem
        $NavInstanceNo ++
    }

    do {
        # Start Menu
        Clear-Host
        Add-BlankLines
        $menuItems | Format-Table -Property No, ServerInstance, Health -AutoSize | Out-Host
        $input = Read-Host "Please select NAV Instance (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedNavInstance = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedNavInstance) { return $selectedNavInstance }
            }
        }
    }
    until ($input -ieq '0')
    
}