$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer

Write-Host "Removing Live Settings for $($DeploymentSettings.instanceName)..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$instanceName,[string]$branchId)   
        $SetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $branchId -Force
        $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
        
        $command = "SELECT [invalididentifierchars] FROM [dbo].[`$ndo`$dbproperty]"
        $invalidChars = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
        $command = "SELECT Name FROM [dbo].[Company] "
        $companies = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
        foreach ($company in $companies.Name) {

            $tableName = "${company}`$Service Password"
            For ($i=0; $i -lt $invalidChars.invalididentifierchars.Length; $i++) { 
                $tableName = $tableName.Replace($invalidChars.invalididentifierchars.SubString($i,1),"_")
            }

            $command = "DELETE FROM [dbo].[${tableName}]"
            $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

            $tableName = "${company}`$Job Queue Entry"
            For ($i=0; $i -lt $invalidChars.invalididentifierchars.Length; $i++) { 
                $tableName = $tableName.Replace($invalidChars.invalididentifierchars.SubString($i,1),"_")
            }

            $command = "DELETE FROM [dbo].[${tableName}]"
            $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

            $tableName = "${company}`$SMTP Mail Setup"
            For ($i=0; $i -lt $invalidChars.invalididentifierchars.Length; $i++) { 
                $tableName = $tableName.Replace($invalidChars.invalididentifierchars.SubString($i,1),"_")
            }

            $command = "DELETE FROM [dbo].[${tableName}]"
            $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command            

            $tableName = "${company}`$Company Information"
            For ($i=0; $i -lt $invalidChars.invalididentifierchars.Length; $i++) { 
                $tableName = $tableName.Replace($invalidChars.invalididentifierchars.SubString($i,1),"_")
            }

            $command = "UPDATE [dbo].[${tableName}] SET [System Indicator] = 5"
            $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command            
            $command = "UPDATE [dbo].[${tableName}] SET [System Indicator Style] = 5"
            $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command            


        }


    } -ArgumentList ($DeploymentSettings.instanceName, $DeploymentSettings.branchId)


$Session | Remove-PSSession