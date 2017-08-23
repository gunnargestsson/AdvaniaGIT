Function Install-DockerAdvaniaGIT {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )

    Invoke-Command -Session $Session -ScriptBlock { 
        param([PSObject]$SetupParameters, [PSObject]$BranchSettings)
        Invoke-WebRequest -Uri "https://github.com/gunnargestsson/AdvaniaGIT/archive/master.zip" -OutFile "C:\Run\AdvaniaGIT.zip" -ErrorAction Stop
        if (Test-Path -Path "C:\Run\AdvaniaGIT.zip") {
            Expand-Archive -LiteralPath "C:\Run\AdvaniaGIT.zip" -DestinationPath "C:\"
            Rename-Item -Path "C:\AdvaniaGIT-master" -NewName "C:\AdvaniaGIT"
            Set-Location -Path "C:\AdvaniaGIT\Scripts"
            & .\Install-Modules.ps1
            $CustomConfigFile =  Join-Path $serviceTierFolder "CustomSettings.config"
            $CustomConfig = [xml](Get-Content $CustomConfigFile)
            $DockerBranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
            $DockerBranchSettings.instanceName = $customConfig.SelectSingleNode("//appSettings/add[@key='ServerInstance']").Value
            $DockerBranchSettings.managementServicesPort = $customConfig.SelectSingleNode("//appSettings/add[@key='ManagementServicesPort']").Value
            $DockerBranchSettings.databaseName = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseName']").Value
            $DockerBranchSettings.databaseInstance = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseInstance']").Value
            $DockerBranchSettings.clientServicesPort = $customConfig.SelectSingleNode("//appSettings/add[@key='ClientServicesPort']").Value
            $DockerBranchSettings.branchId = $BranchSettings.branchId
            $DockerBranchSettings.databaseServer = $customConfig.SelectSingleNode("//appSettings/add[@key='DatabaseServer']").Value
            Update-BranchSettings -BranchSettings $DockerBranchSettings 
        } else {
            Write-Error "AdvaniaGIT Module Installation failed!" -ErrorAction Stop
        }
    } -ArgumentList ($SetupParameters, $BranchSettings)
}