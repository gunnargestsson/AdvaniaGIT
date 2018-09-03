function Load-Menu
{    
    $menuItems = @()
    $containers = Get-DockerContainers
    $containerNo = 1
    foreach ($container in $containers) {        
        $containerBranchSettings = Get-DockerBranchSettings -DockerContainerName $container.Names
        $containerConfiguration = Get-DockerContainerConfiguration -DockerContainerName $container.Names
        $container | Add-Member -MemberType NoteProperty -Name No -Value $containerNo
        $container.Id = $containerConfiguration.Id
        $container | Add-Member -MemberType NoteProperty -Name InstanceName -Value $containerBranchSettings.instanceName
        $container | Add-Member -MemberType NoteProperty -Name BranchId -Value $containerBranchSettings.branchId
        $container | Add-Member -MemberType NoteProperty -Name ProjectName -Value $containerBranchSettings.projectName
        $menuItems += $container
        $containerNo ++
    }
    Return $menuItems
}

do {
    $menuItems = Load-Menu
    Clear-Host
    Add-BlankLines -SetupParameters $SetupParameters
    $menuItems | Format-Table -Property No, ProjectName, Names, Status, InstanceName, BranchId, Image -AutoSize 
    $input = Read-Host "Please select container number (0 = exit)"
    switch ($input) {
        '0' { break }
        default {
            $selectedContainer = $menuItems | Where-Object -Property No -EQ $input
            if ($selectedContainer) {
                do {
                    Clear-Host
                    Add-BlankLines -SetupParameters $SetupParameters
                    $selectedContainer | Format-Table -Property No, ProjectName, Name, Status, InstanceName, BranchId, Image -AutoSize 
                    $input = Read-Host "Please select action (
                    0 = return, 
                    1 = restart, 
                    2 = stop,
                    3 = remove)"
                    switch ($input) {
                        '0' { 
                                $input = "q"
                                break 
                            }
                        '1' {
                                $ContainerBranchSettings = New-Object -TypeName PSObject
                                $ContainerBranchSettings | Add-Member -MemberType NoteProperty -Name dockerContainerName -Value $selectedContainer.Names
                                $ContainerBranchSettings | Add-Member -MemberType NoteProperty -Name dockerContainerId -Value $selectedContainer.Id
                                ReStart-DockerContainer -BranchSettings $ContainerBranchSettings 
                            }
                        '2' {
                                Write-Host "Stopping Docker Container $($selectedContainer.Names)..."
                                $dockerContainerName = docker.exe stop $($selectedContainer.Names)
                            }
                        '3' {
                                
                                Write-Host "Stopping and removing Docker Container $($selectedContainer.Names)..."
                                if ($selectedContainer.Status.Contains("Up")) {
                                    $dockerContainerName = docker.exe stopp $($selectedContainer.Names)
                                }
                                $dockerContainerName = docker.exe rm $($selectedContainer.Names)
                                Edit-DockerHostRegistration -RemoveHostName $selectedContainer.Names
                                if ($selectedContainer.branchId -gt "") { 
                                    $BranchSettings = Clear-BranchSettings -BranchId $BranchSettings.branchId
                                } 
                            }                            
                    }                    
                }
                until ($input -iin ('q', '1', '2', '3'))
            }
        }
    }
}
until ($input -ieq '0')
