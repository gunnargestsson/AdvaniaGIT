Function Remove-NAVRemoteWebInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    PROCESS 
    {
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                param(
                    [String]$ServerInstance)
                Write-Verbose "Import Module from $($SetupParameters.navServicePath)..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Write-Host "Removing Web Client Site for ${ServerInstance}..."
                if ([int]$SetupParameters.mainVersion -ge 110) {
                    if (Get-NAVWebServerInstance -WebServerInstance $ServerInstance) { Remove-NAVWebServerInstance -WebServerInstance $ServerInstance }
                    if (Get-NAVWebServerInstance -WebServerInstance "${ServerInstance}365") { Remove-NAVWebServerInstance -WebServerInstance "${ServerInstance}365" }
                    if (Get-NAVWebServerInstance -WebServerInstance "${ServerInstance}Test") { Remove-NAVWebServerInstance -WebServerInstance "${ServerInstance}Test" }
                } else {
                    Get-NAVWebServerInstance -WebServerInstance $ServerInstance | Remove-NAVWebServerInstance -Force
                    Get-NAVWebServerInstance -WebServerInstance "${ServerInstance}365" | Remove-NAVWebServerInstance -Force
                    Get-NAVWebServerInstance -WebServerInstance "${ServerInstance}Test" | Remove-NAVWebServerInstance -Force
                }
                UnLoad-InstanceAdminTools
                Start-Sleep -Seconds 2
            } -ArgumentList $SelectedInstance.ServerInstance
    }    
}