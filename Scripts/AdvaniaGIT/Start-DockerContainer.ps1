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
    [String]$MemoryLimit = ""
    )
    
    if (![Bool](Get-Module NAVContainerHelper)) {
        if ([Bool](Get-Module NAVContainerHelper -ListAvailable)) {
            if (!$SetupParameters.BuildMode) { Write-Host -ForegroundColor Green "Using NAV Container Helper from @freddydk..." }
            Import-Module NAVContainerHelper -DisableNameChecking
        } else {
            Write-Host -ForegroundColor Red "NAV Container Helper is required.  Please use the VS Code command to install NAV container helper!"
            throw
        }
    }    
    
    $DockerSettings = Get-DockerSettings 
    $DockerCreated = $false

    $HasNetworkConnection = ($null -ne (Resolve-DnsName -QuickTimeout -Name $DockerSettings.RepositoryPath -ErrorAction SilentlyContinue))
    if ([System.String]::IsNullOrEmpty($AdminPassword)) {
        $DockerCredentials = Get-DockerAdminCredentials -Message "Enter credentials for the Docker Container" -DefaultUserName $AdminUsername
        $AdminPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DockerCredentials.Password))
    } else {
        $DockerCredentials = New-Object System.Management.Automation.PSCredential($env:USERNAME, (ConvertTo-SecureString $AdminPassword -AsPlainText -Force))
    }

    Write-Host "Connecting to repository $($DockerSettings.RepositoryPath)..."
    if ($DockerSettings.RepositoryPassword -gt "" -and $HasNetworkConnection) {
        try {
            docker.exe login $($DockerSettings.RepositoryPath) -u $($DockerSettings.RepositoryUserName) -p $($DockerSettings.RepositoryPassword)
        }
        catch {
            Write-Host -ForegroundColor Red "Unable to login to docker repository: $($DockerSettings.RepositoryPath)"
        }

    }

    Write-Host "Preparing Docker Container for Dynamics NAV..."    
    
    $imageName = $SetupParameters.dockerImage

    $volume = "$($SetupParameters.Repository):C:\GIT"
    $rootPath = "$($SetupParameters.rootPath):C:\Host"
    $parameters = @(
                "--volume `"$volume`"",
                "--volume `"$rootPath`"",
                "--env SqlTimeout=1200",
                "--dns 8.8.8.8",
                "--restart always")


    if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
        if ($SetupParameters.BuildMode) {
            $parameters += @("--env webClient=N",
                             "--env httpSite=N")        
        }
    }

    if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
        if (![System.String]::IsNullOrEmpty($SetupParameters.mapAddInFolder)) {
            $branchAddInsFolder = "$($SetupParameters.Repository)\Add-Ins"
            if (Test-Path -Path $branchAddInsFolder -PathType Container ) { 
                $branchAddInsFolder = "$($SetupParameters.Repository)\Add-Ins:c:\run\Add-Ins"
                $parameters += @(
                                    "--volume `"$branchAddInsFolder`""
                                )
            }
        }
    }

    if (![System.String]::IsNullOrEmpty($BackupFilePath)) {
        $BackupFilePath = $BackupFilePath.Replace($SetupParameters.rootPath,"C:\Host")
        $parameters += @(
                            "--env bakfile=`"$BackupFilePath`""
                        )
    }


    $params = @{ 
        additionalParameters = $parameters
        doNotExportObjectsToText = $true 
        shortcuts = 'None'
        }
        
    if (![System.String]::IsNullOrEmpty($LicenseFilePath)) {
        $params += @{ licensefile = "$LicenseFilePath" }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.dockerTestToolkit)) {
        $params += @{ includeTestToolkit = $SetupParameters.dockerTestToolkit }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.dockerTestLibraries)) {
        $params += @{ includeTestToolkit = $true }
        $params += @{ includeTestLibrariesOnly = $SetupParameters.dockerTestLibraries }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.dockerAuthentication)) {
        $params += @{ auth = $SetupParameters.dockerAuthentication }
    } elseif ($env:USERDOMAIN -eq "AzureAD") {
        $params += @{ auth = "NavUserpassword" }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.dockerEnableSymbolLoading)) {
        $params += @{ enableSymbolLoading = $true }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.useBestContainerOS)) {    
        $params += @{ useBestContainerOS = $true }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.dockerIsolation)) {    
        $params += @{ isolation = $SetupParameters.dockerIsolation }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.CheckHealth )) {    
        $params += @{ doNotCheckHealth  = $true }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.includeAL)) {    
        $params += @{ includeAL = $true }
    }

    if (![System.String]::IsNullOrEmpty($SetupParameters.dockerAssignPremiumPlan)) {    
        $params += @{ assignPremiumPlan = $SetupParameters.dockerAssignPremiumPlan }
    }

    if ([int]($SetupParameters.navVersion).split(".")[0] -lt 15) {
        $params += @{ includeCSide = $true }
    }

    if ($HasNetworkConnection) {
        $params += @{ alwaysPull = $true }
    }

    if ($SetupParameters.BuildMode) {
        $DockerContainerFriendlyName = "BC$((New-Guid).ToString().Replace('-','').Substring(0,13))"
    } else {
        if (![System.String]::IsNullOrEmpty($SetupParameters.dockerFriendlyName)) {
            $DockerContainerFriendlyName = $SetupParameters.dockerFriendlyName
        } else {
            $DockerContainerFriendlyName = "$($SetupParameters.projectName)               ".Substring(0,15).TrimEnd(" ") -replace '_','-'
        }
    }
    if ((Get-NavContainers) -inotcontains $DockerContainerFriendlyName) { 
        New-NavContainer -accept_eula -accept_outdated  -imageName $imageName -containerName $DockerContainerFriendlyName -Credential $DockerCredentials @params -restart no -updateHosts -EnableTaskScheduler:$false
        $DockerCreated = $true
    }
    $DockerContainerId = Get-NavContainerId -containerName $DockerContainerFriendlyName 
   

    if ($DockerCreated) { 
        $DockerSettings = Install-DockerAdvaniaGIT -SetupParameters $SetupParameters -BranchSettings $BranchSettings -containerName $DockerContainerFriendlyName
    } else {
        $DockerSettings = Get-DockerAdvaniaGITConfig -SetupParameters $SetupParameters -BranchSettings $BranchSettings -containerName $DockerContainerFriendlyName 
    } 
    $DockerContainerIpAddress = Get-NavContainerIpAddress -containerName $DockerContainerFriendlyName
   

    $BranchSettings.databaseServer = $DockerContainerFriendlyName
    $BranchSettings.dockerContainerName = $DockerContainerFriendlyName
    $BranchSettings.dockerContainerId = $DockerContainerId
    $BranchSettings.dockerContainerIp = $DockerContainerIpAddress
    $BranchSettings.clientServicesPort = $DockerSettings.BranchSettings.clientServicesPort
    $BranchSettings.managementServicesPort = $DockerSettings.BranchSettings.managementServicesPort
    $BranchSettings.developerServicesPort = $DockerSettings.BranchSettings.developerServicesPort
    $BranchSettings.databaseInstance = $DockerSettings.BranchSettings.databaseInstance
    $BranchSettings.databaseName = $DockerSettings.BranchSettings.databaseName
    $BranchSettings.instanceName = $DockerSettings.BranchSettings.instanceName

    Update-BranchSettings -BranchSettings $BranchSettings
    if ($passwordKeyHostFile) {
        Remove-Item -Path $passwordKeyHostFile -Force -ErrorAction SilentlyContinue
    }
}
