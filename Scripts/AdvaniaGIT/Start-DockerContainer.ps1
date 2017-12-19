function Start-DockerContainer
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$AdminUsername = $env:USERNAME,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$AdminPassword,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$BackupFilePath,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$LicenseFilePath,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$MemoryLimit = "3G"
    )
    
    $DockerSettings = Get-DockerSettings 
    Write-Host "Connecting to repository $($DockerSettings.RepositoryPath)..."
    if ($DockerSettings.RepositoryPassword -gt "") {
        try {
            docker.exe login $($DockerSettings.RepositoryPath) -u $($DockerSettings.RepositoryUserName) -p $($DockerSettings.RepositoryPassword)
        }
        catch {
            Write-Host -ForegroundColor Red "Unable to login to docker repository: $($DockerSettings.RepositoryPath)"
        }

    }

    if ([System.String]::IsNullOrEmpty($AdminPassword)) {
        $DockerCredentials = Get-DockerAdminCredentials -Message "Enter credentials for the Docker Container" -DefaultUserName $AdminUsername
        $AdminPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DockerCredentials.Password))
    }

    Write-Host "Preparing Docker Container for Dynamics NAV..."    
    
    $imageName = $SetupParameters.dockerImage
    docker.exe pull $imageName

    $volume = "$($SetupParameters.Repository):C:\GIT"
    $rootPath = "$($SetupParameters.rootPath):C:\Host"
    $genericTag = (docker.exe inspect $imageName | ConvertFrom-Json).Config.Labels.tag

    $parameters = @(
                "--env auth=Windows"
                "--env username=$adminUsername",
                "--env ExitOnError=N",
                "--env ACCEPT_EULA=Y",
                "--memory $MemoryLimit",
                "--volume `"$volume`"",
                "--volume `"$rootPath`"",
                "--restart always",
                "--env SqlTimeout=1200",
                "--env locale=$((Get-Culture).Name)"
                )

    Write-Host "Docker Container starting..."

    if (![System.String]::IsNullOrEmpty($BackupFilePath)) {
        $BackupFilePath = $BackupFilePath.Replace($SetupParameters.rootPath,"C:\Host")
        $parameters += @(
                            "--env bakfile=$BackupFilePath"
                        )
    }

    if (![System.String]::IsNullOrEmpty($LicenseFilePath)) {
        $LicenseFilePath = $LicenseFilePath.Replace($SetupParameters.rootPath,"C:\Host")
        $parameters += @(
                            "--env licensefile=$LicenseFilePath"
                        )
    }

    if ([System.Version]$genericTag -ge [System.Version]"0.0.3.0") {
        $passwordKeyHostFile = Join-Path $($SetupParameters.LogPath) "aes.key"
        $logFolder = Split-Path $SetupParameters.LogPath -Leaf
        $passwordKeyFile = Join-Path (Join-Path (Join-Path "C:\Host" (Split-Path (Split-Path $SetupParameters.LogPath -Parent) -Leaf)) $logFolder) "aes.key"
        $passwordKey = New-Object Byte[] 16
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($passwordKey)
        Set-Content -Path $passwordKeyHostFile -Value $passwordKey
        $encPassword = ConvertFrom-SecureString -SecureString (ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force) -Key $passwordKey
            
        $parameters += @(
                            "--env securePassword=$encPassword",
                            "--env passwordKeyFile=""$passwordKeyFile""",
                            "--env removePasswordKeyFile=Y"
                        )            
        $DockerContainerId = Start-DockerRun -accept_eula -accept_outdated -imageName $imageName -parameters $parameters
    } else {
        $parameters += "--env password=""$AdminPassword"""
        $DockerContainerId = Start-DockerRun -accept_eula -accept_outdated -imageName $imageName -parameters $parameters
    }

    $NoOfLogLines = 0
    $WaitForHealty = $true
    $LoopNo = 1
    while ($WaitForHealty -and $LoopNo -lt 100) {
        $log = (docker.exe logs $DockerContainerId) | Select-Object -Skip $NoOfLogLines
        $NoOfLogLines += $log.Count
        if ($log.Count -gt 0) {
            Write-Host "$([string]::Join("`r`n",$log))"
            $WaitForHealty = (!($log.Contains("Ready for connections!")))
        }
        if ($WaitForHealty) { Start-Sleep -Seconds 4 }
        $LoopNo ++
    }       

    $DockerConfig = docker.exe inspect $DockerContainerId
    $DockerContainerName = ($DockerConfig | ConvertFrom-Json).Config[0].HostName
    $DockerContainerFriendlyName = Split-Path ($DockerConfig | ConvertFrom-Json).Name -Leaf
    $dockerContainer = Get-DockerContainers | Where-Object -Property Id -ieq $DockerContainerName

    $WaitForHealty = $true
    $LoopNo = 1
    while ($WaitForHealty -and $LoopNo -lt 20) {        
        $dockerContainer = Get-DockerContainers | Where-Object -Property Id -ieq $DockerContainerName
        Write-Host "Container status: $($dockerContainer.Status)..."
        $WaitForHealty = $dockerContainer.Status -match "(health: starting)"
        if ($WaitForHealty) { Start-Sleep -Seconds 10 }
        $LoopNo ++
    }

    if (!($dockerContainer.Status -match "(healthy)")) {
        $logs = docker.exe logs $DockerContainerName
        Write-Host -ForegroundColor Red "$([string]::Join("`r`n",$logs))"
        Write-Host -ForegroundColor Red "Status: $($dockerContainer.Status)"
        Write-Error "Container $DockerContainerName unable to start !" -ErrorAction Stop
    }

    $Session = New-DockerSession -DockerContainerId $DockerContainerId
    $DockerSettings = Install-DockerAdvaniaGIT -Session $Session -SetupParameters $SetupParameters -BranchSettings $BranchSettings 
    Edit-DockerHostRegiststration -AddHostName $DockerContainerName -AddIpAddress (Get-DockerIPAddress -Session $Session)

    $BranchSettings.databaseServer = $DockerContainerName
    $BranchSettings.dockerContainerName = $DockerContainerName
    $BranchSettings.dockerContainerId = $DockerContainerId
    $BranchSettings.clientServicesPort = $DockerSettings.BranchSettings.clientServicesPort
    $BranchSettings.managementServicesPort = $DockerSettings.BranchSettings.managementServicesPort
    $BranchSettings.developerServicesPort = $DockerSettings.BranchSettings.developerServicesPort
    $BranchSettings.databaseInstance = $DockerSettings.BranchSettings.databaseInstance
    $BranchSettings.databaseName = $DockerSettings.BranchSettings.databaseName
    $BranchSettings.instanceName = $DockerSettings.BranchSettings.instanceName

    Update-BranchSettings -BranchSettings $BranchSettings
    Remove-PSSession -Session $Session 
    if ($passwordKeyHostFile) {
        Remove-Item -Path $passwordKeyHostFile -Force -ErrorAction SilentlyContinue
    }
}
