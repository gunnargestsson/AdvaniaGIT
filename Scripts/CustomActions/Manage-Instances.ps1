function Load-Menu
{
    Load-InstanceAdminTools -SetupParameters $SetupParameters
    $menuItems = @()
    $instances = Get-NAVServerInstance | Where-Object -Property Version -Like ($SetupParameters.navVersion.Substring(0,2) + "*.0")
    $instanceNo = 1
    foreach ($instance in $instances) {
        $instanceName = $instance.ServerInstance.Substring(27,$instance.ServerInstance.Length - 27)
        $instanceBranchSettings = Get-InstanceBranchSettings -InstanceName $instanceName
        $instance | Add-Member -MemberType NoteProperty -Name No -Value $instanceNo
        $instance | Add-Member -MemberType NoteProperty -Name InstanceName -Value $instanceName
        $instance | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $instanceBranchSettings.databaseName
        $instance | Add-Member -MemberType NoteProperty -Name BranchId -Value $instanceBranchSettings.branchId
        $instance | Add-Member -MemberType NoteProperty -Name ProjectName -Value $instanceBranchSettings.projectName
        $menuItems += $instance
        $instanceNo ++
    }
    UnLoad-InstanceAdminTools
    Return $menuItems
}

do {
    $menuItems = Load-Menu
    Clear
    $menuItems | Format-Table -Property No, ProjectName, InstanceName, State, DatabaseName, Version, Default, BranchId -AutoSize 
    $input = Read-Host "Please select instance number (q = exit)"
    switch ($input) {
        'q' { break }
        default {
            $selectedInstance = $menuItems | Where-Object -Property No -EQ $input
            if ($selectedInstance) {
                do {
                    Clear
                    $selectedInstance | Format-Table -Property No, ProjectName, InstanceName, State, DatabaseName, Version, Default, BranchId -AutoSize
                    $input = Read-Host "Please select action (r = return, d = delete, s = start, x = stop, e = event log)"
                    switch ($input) {
                        'r' { break }
                        'd' { 
                                $InstanceSetupParameters = Create-SetupParameters -InstanceVersion $selectedInstance.Version
                                Load-InstanceAdminTools -SetupParameters $InstanceSetupParameters
                                if ($selectedInstance.branchId -ne "") {
                                    $LocalBranchSettings = Clear-BranchSettings -BranchId $selectedInstance.branchId 
                                    Remove-NAVEnvironment -BranchSettings $LocalBranchSettings 
                                } else {
                                        Write-Host "Removing Web Server Instance..."
                                        Get-NAVWebServerInstance -WebServerInstance $selectedInstance.instanceName | Remove-NAVWebServerInstance  -Force
                                        Write-Host "Removing Server Instance..."
                                        Get-NAVServerInstance -ServerInstance $selectedInstance.instanceName | Remove-NAVServerInstance -Force
                                        if ($selectedInstance.databaseName -ne "") {
                                            Write-Host "Removing Database..."
                                            Get-SQLCommandResult -Server (Get-DefaultDatabaseServer -SetupParameters $SetupParameters) -Database master -Command "DROP DATABASE [$($selectedInstance.databaseName)]" | Out-Null                                        
                                        }
                                }                                
                                UnLoad-InstanceAdminTools
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        's' {
                                $InstanceSetupParameters = Create-SetupParameters -InstanceVersion $selectedInstance.Version
                                Load-InstanceAdminTools -SetupParameters $InstanceSetupParameters
                                Set-NAVServerInstance -ServerInstance $selectedInstance.instanceName -Start -Force
                                UnLoad-InstanceAdminTools
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        'x' {
                                $InstanceSetupParameters = Create-SetupParameters -InstanceVersion $selectedInstance.Version
                                Load-InstanceAdminTools -SetupParameters $InstanceSetupParameters
                                Set-NAVServerInstance -ServerInstance $selectedInstance.instanceName -Stop -Force
                                UnLoad-InstanceAdminTools
                                $anyKey = Read-Host "Press enter to continue..."
                            }
                        'e' {
                                Show-InstanceEvents -InstanceName $selectedInstance.instanceName
                                $anyKey = Read-Host "Press enter to continue..."
                            }                                
                    }                    
                }
                until ($input -iin ('r', 'd', 's', 'e', 'x'))
            }
        }
    }
}
until ($input -ieq 'q')



