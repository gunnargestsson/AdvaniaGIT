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
    UnLoad-InstanceAdminTools
    Return $menuItems
}

do {
    $menuItems = Load-Menu
    Clear-Host
    For ($i=0; $i -le 10; $i++) { Write-Host "" }
    $menuItems | Format-Table -Property No, ProjectName, DatabaseName, State, InstanceName, Version, Default, BranchId -AutoSize 
    $input = Read-Host "Please select database number (0 = exit)"
    switch ($input) {
        '0' { break }
        default {
            $selectedDatabase = $menuItems | Where-Object -Property No -EQ $input
            if ($selectedDatabase) {
                do {
                    Clear-Host
                    For ($i=0; $i -le 10; $i++) { Write-Host "" }
                    $selectedDatabase | Format-Table -Property No, ProjectName, DatabaseName, State, InstanceName, Version, Default, BranchId -AutoSize 
                    $databaseBranchSettings = Get-DatabaseBranchSettings -DatabaseName $selectedDatabase.DatabaseName
                    $InstanceSetupParameters = Create-SetupParameters -SetupParameters $SetupParameters -InstanceVersion $selectedDatabase.Version
                    $input = Read-Host "Please select action (
                    0 = return, 
                    1 = remove users, 
                    2 = remove service passwords,
                    3 = create backup, 
                    4 = restore backup, 
                    5 = create bacpac, 
                    6 = restore backpac,
                    7 = create navdata,
                    8 = restore navdata, 
                    9 = delete)"
                    switch ($input) {
                        '0' { 
                                $input = "q"
                                break 
                            }
                        '1' {
                                Remove-NAVDatabaseUsers -SetupParameters $InstanceSetupParameters -BranchSettings $databaseBranchSettings
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        '2' {
                                Remove-NAVDatabaseServicePasswords -SetupParameters $InstanceSetupParameters -BranchSettings $databaseBranchSettings
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        '3' {
                                if ($selectedDatabase.branchId -eq "") { 
                                    Write-Host -ForegroundColor Red "Environment must be attached to use this function"
                                    break
                                } else {
                                    $BackupFileName = Read-Host -Prompt "Type backup file name (default = $($databaseBranchSettings.DatabaseName).bak)"
                                    if ($BackupFileName -eq "") { $BackupFileName = "$($databaseBranchSettings.DatabaseName).bak" }
                                    Create-NAVDatabaseBackup -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings -BackupFilePath (Join-Path $SetupParameters.BackupPath $BackupFileName)
                                }
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        '4' {
                                if ($selectedDatabase.branchId -eq "") { 
                                    Write-Host -ForegroundColor Red "Environment must be attached to use this function"
                                    break
                                } else {
                                    $SelectedBakFilePath = Get-LocalBakFilePath
                                    Replace-NAVDatabaseFromBak -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings -SelectedBackupFile $SelectedBakFilePath.FullName 
                                }
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        '5' {
                                if ($selectedDatabase.branchId -eq "") { 
                                    Write-Host -ForegroundColor Red "Environment must be attached to use this function"
                                    break
                                } else {
                                    $BacpacFileName = Read-Host -Prompt "Type bacpac file name (default = $($databaseBranchSettings.DatabaseName).bacpac)"
                                    if ($BacpacFileName -eq "") { $BacpacFileName = "$($databaseBranchSettings.DatabaseName).bacpac" }
                                    Create-NAVDatabaseBacpac -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings -BacpacFilePath (Join-Path $SetupParameters.BackupPath $BacpacFileName)
                                }
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        '6' {
                                if ($selectedDatabase.branchId -eq "") { 
                                    Write-Host -ForegroundColor Red "Environment must be attached to use this function"
                                    break
                                } else {
                                    $SelectedBakFilePath = Convert-NAVBacpacToBak -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings
                                    Replace-NAVDatabaseFromBak -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings -SelectedBackupFile $SelectedBakFilePath 
                                }
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        '7' {
                                if ($selectedDatabase.branchId -eq "") { 
                                    Write-Host -ForegroundColor Red "Environment must be attached to use this function"
                                    break
                                } else {
                                    $NavdataFileName = Read-Host -Prompt "Type navdata file name (default = $($databaseBranchSettings.DatabaseName).navdata)"
                                    if ($NavdataFileName -eq "") { $NavdataFileName = "$($databaseBranchSettings.DatabaseName).Navdata" }
                                    Create-NAVDatabaseNavdata -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings -NavdataFilePath (Join-Path $SetupParameters.BackupPath $NavdataFileName)
                                }
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        '8' {
                                if ($selectedDatabase.branchId -eq "") { 
                                    Write-Host -ForegroundColor Red "Environment must be attached to use this function"
                                    break
                                } else {
                                    $SelectedBakFilePath = Convert-NAVnavdataToBak -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings
                                    Replace-NAVDatabaseFromBak -SetupParameters $SetupParameters -BranchSettings $databaseBranchSettings -SelectedBackupFile $SelectedBakFilePath 
                                }
                                $anyKey = Read-Host "Press enter to continue..."
                            }

                            
                        '9' { 
                                if ($selectedDatabase.branchId -ne "") {
                                    Load-InstanceAdminTools -SetupParameters $InstanceSetupParameters
                                    $LocalBranchSettings = Clear-BranchSettings -BranchId $selectedDatabase.branchId 
                                    Remove-NAVEnvironment -BranchSettings $LocalBranchSettings 
                                    UnLoad-InstanceAdminTools
                                } else {
                                    Write-Host "Removing Database..."
                                    Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command "ALTER DATABASE [$($selectedDatabase.databaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$($selectedDatabase.databaseName)]" | Out-Null
                                }                                
                                $anyKey = Read-Host "Press enter to continue..."
                            }                               
                    }                    
                }
                until ($input -iin ('q', '7'))
            }
        }
    }
}
until ($input -ieq '0')

