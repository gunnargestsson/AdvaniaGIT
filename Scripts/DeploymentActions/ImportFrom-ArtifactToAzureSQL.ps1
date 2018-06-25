$DbAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.SqlServerPid
$VMAdmin = Get-NAVPasswordStateUser -PasswordId $DeploymentSettings.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = $DeploymentSettings.workFolder
New-Item -Path $WorkFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
Write-Host "Connecting to $($DeploymentSettings.instanceServer)..."
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $DeploymentSettings.instanceServer -SetupPath $WorkFolder

Write-Host "Updating Branch Settings on remote server..."
Invoke-Command -Session $Session -ScriptBlock {
    param([string]$branchId,[string]$instanceName)
    Write-Host "Updating branch settings for ${branchId}..."
    $SetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $branchId
    $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
    $BranchSettings.instanceName = $instanceName
    $InstanceSettings = Get-InstanceSettings -SetupParameters $SetupParameters -BranchSettings $BranchSettings
    $BranchSettings.databaseServer = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseServer']").Attributes["value"].Value
    $BranchSettings.databaseName = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='DatabaseName']").Attributes["value"].Value
    $BranchSettings.clientServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value
    $BranchSettings.managementServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value 
    Update-BranchSettings -BranchSettings $BranchSettings
} -ArgumentList ($DeploymentSettings.branchId, $DeploymentSettings.instanceName)

$ObjectsFiles = Get-ChildItem -Path (Get-Location).Path -Filter *.fob
foreach ($ObjectsFile in $ObjectsFiles) {
    Write-Host "Uploading Artifact $($ObjectsFile.Name) to remote server..."
    Compress-Archive -Path $ObjectsFile.FullName -DestinationPath (Join-Path $WorkFolder 'Objects.zip') -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $WorkFolder 'Objects.zip') -DestinationFile (Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-Objects.zip") 
    Remove-Item -Path (Join-Path $WorkFolder 'Objects.zip')  -Force -ErrorAction SilentlyContinue

    Write-Host "Expanding $($ObjectsFile.Name) on remote server..."
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ZipFileName,[string]$ObjectFilePath)
        New-Item -Path $ObjectFilePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        Expand-Archive -Path $ZipFileName -DestinationPath $ObjectFilePath -Force
        Remove-Item -Path $ZipFileName -Force -ErrorAction SilentlyContinue
    } -ArgumentList ((Join-Path $WorkFolder "$($DeploymentSettings.instanceName)-Objects.zip"), "$WorkFolder\$($DeploymentSettings.instanceName)")

    Write-Host "Importing $($ObjectsFile.Name)..."
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$file,[string]$username,[string]$password)
        $logFile = "$($SetupPatameters.LogPath)\$((Get-Item $file).BaseName).log"             
        $command = "Command=ImportObjects`,ImportAction=Overwrite`,SynchronizeSchemaChanges=No`,File=`"$file`"" 
                    
        Run-NavIdeCommand -SetupParameters $SetupParameters `
                        -BranchSettings $BranchSettings `
                        -Command $command `
                        -LogFile $logFile `
                        -Username $username `
                        -Password $password `
                        -StopOnError
                        
        Remove-Item -Path $file  -Force -ErrorAction SilentlyContinue
    } -ArgumentList ((Join-Path "$WorkFolder\$($DeploymentSettings.instanceName)" $ObjectsFile.Name),$DbAdmin.Username,$DbAdmin.Password)

    Write-Host "Syncronizing changes..."
    Invoke-Command -Session $Session -ScriptBlock {
        Load-InstanceAdminTools -SetupParameters $SetupParameters
        Get-NAVTenant -ServerInstance $BranchSettings.instanceName | Sync-NAVTenant -Mode ForceSync -Force
    }

    Write-Host "Import complete..."
}

$Session | Remove-PSSession
