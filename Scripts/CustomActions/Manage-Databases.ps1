function Load-Menu
{    
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    $menuItems = @()
    $databases = Get-DatabaseNames -SetupParameters $SetupParameters | Where-Object -Property Name -Match "NAV$($Setupparameters.navRelease)DEV" | Sort-Object -Property Name
    $databaseNo = 1
    foreach ($database in $databases) {        
        $databaseBranchSettings = Get-DatabaseBranchSettings -DatabaseName $database.Name
        $database | Add-Member -MemberType NoteProperty -Name No -Value $databaseNo
        $database | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $database.Name
        $database | Add-Member -MemberType NoteProperty -Name InstanceName -Value $databaseBranchSettings.instanceName
        $database | Add-Member -MemberType NoteProperty -Name BranchId -Value $databaseBranchSettings.branchId
        $database | Add-Member -MemberType NoteProperty -Name ProjectName -Value $databaseBranchSettings.projectName
        if ($databaseBranchSettings.instanceName -ne "") {
            $instanceSettings = Get-NAVServerInstance -ServerInstance $databaseBranchSettings.instanceName
            $database | Add-Member -MemberType NoteProperty -Name State -Value $instanceSettings.State
            $database | Add-Member -MemberType NoteProperty -Name Version -Value $instanceSettings.Version
            $database | Add-Member -MemberType NoteProperty -Name Default -Value $instanceSettings.Default
        }
        $menuItems += $database
        $databaseNo ++
    }
    UnLoad-databaseAdminTools
    Return $menuItems
}

do {
    $menuItems = Load-Menu
    Clear
    $menuItems | Format-Table -Property No, ProjectName, DatabaseName, State, InstanceName, Version, Default, BranchId -AutoSize 
    $input = Read-Host "Please select database number (q = exit)"
    switch ($input) {
        'q' { break }
        default {
            $selectedDatabase = $menuItems | Where-Object -Property No -EQ $input
            if ($selectedDatabase) {
                do {
                    Clear
                    $selectedDatabase | Format-Table -Property No, ProjectName, DatabaseName, State, InstanceName, Version, Default, BranchId -AutoSize 
                    $input = Read-Host "Please select action (r = return, d = delete)"
                    switch ($input) {
                        'r' { break }
                        'd' { 
                                if ($selectedDatabase.branchId -ne "") {
                                    $InstanceSetupParameters = Create-SetupParameters -InstanceVersion $selectedDatabase.Version
                                    Load-InstanceAdminTools -SetupParameters $InstanceSetupParameters
                                    $LocalBranchSettings = Clear-BranchSettings -BranchId $selectedDatabase.branchId 
                                    Remove-NAVEnvironment -BranchSettings $LocalBranchSettings 
                                    UnLoad-InstanceAdminTools
                                } else {
                                    Write-Host "Removing Database..."
                                    Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command "DROP DATABASE [$($selectedDatabase.databaseName)]" | Out-Null                                        
                                }                                
                                $anyKey = Read-Host "Press enter to continue..."
                            }                               
                    }                    
                }
                until ($input -iin ('r', 'd'))
            }
        }
    }
}
until ($input -ieq 'q')

