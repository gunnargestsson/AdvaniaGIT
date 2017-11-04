Function Set-NAVRemoteDockerContainerWebServerInstanceToNAVUserPassword
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        $Session = New-DockerSession -DockerContainerId $BranchSettings.DockerContainerId
        Invoke-Command -Session $Session -ScriptBlock `
        {            
            Import-Module AdvaniaGIT | Out-Null
            $SetupParameters = Get-GITSettings
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters

            $wwwRootPath = (Get-Item "HKLM:\SOFTWARE\Microsoft\InetStp").GetValue("PathWWWRoot")
            $wwwRootPath = Join-Path ([System.Environment]::ExpandEnvironmentVariables($wwwRootPath)) $BranchSettings.instanceName
            if (Test-Path (Join-Path $wwwRootPath "navsettings.json")) {
                $navSettings = Get-Content -Path (Join-Path $wwwRootPath "navsettings.json") -Encoding UTF8 | Out-String | ConvertFrom-Json
                $navSettings.NAVWebSettings.ClientServicesCredentialType = "NavUserPassword"
                Set-Content -Path (Join-Path $wwwRootPath "navsettings.json") -Encoding UTF8 -Value (ConvertTo-Json $navSettings)               
            } else {
                [xml]$WebConfig = Get-Content -Path (Join-Path $wwwRootPath "web.config") -Encoding UTF8
                $WebConfig.configuration.DynamicsNAVSettings.SelectSingleNode("add[@key='ClientServicesCredentialType']").Attributes["value"].Value = "NavUserPassword"
                Set-Content -Path (Join-Path $wwwRootPath "web.config") -Encoding UTF8 -Value $WebConfig.OuterXml
            } 
            Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/windowsAuthentication" -Name Enabled -Value True -PSPath IIS:\ -Location "NavWebApplicationContainer"

        } 
        Remove-PSSession $Session
    } 
}