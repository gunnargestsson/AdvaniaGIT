Function Remove-NAVRemoteInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ServerInstance
    )
    PROCESS 
    { 
        # Create the ClickOnce Site
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([String]$ServerInstance)
                Write-Host "Removing Service Instance ${ServerInstance}..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                [xml]$InstanceSettings = Get-NAVServerConfiguration -AsXml -ServerInstance (Get-NAVServerInstance | Where-Object {$_.Default -eq $true}).ServerInstance
                $ManagementServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value
                $ClientServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value

                Get-NAVServerInstance -ServerInstance $ServerInstance | Remove-NAVServerInstance -Force
                UnLoad-InstanceAdminTools
            } -ArgumentList $ServerInstance -ErrorAction Stop
    }    
}