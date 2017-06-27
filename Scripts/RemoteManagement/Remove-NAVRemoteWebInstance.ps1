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
                Get-NAVWebServerInstance -WebServerInstance $ServerInstance | Remove-NAVWebServerInstance -Force
                UnLoad-InstanceAdminTools
                Start-Sleep -Seconds 2
            } -ArgumentList $SelectedInstance.ServerInstance
    }    
}