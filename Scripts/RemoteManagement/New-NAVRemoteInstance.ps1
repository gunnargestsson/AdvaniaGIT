Function New-NAVRemoteInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ServerInstance
    )
    PROCESS 
    { 
        Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([String]$ServerInstance)
                Write-Host "Creating Service Instance..."
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                [xml]$InstanceSettings = Get-NAVServerConfiguration -AsXml -ServerInstance (Get-NAVServerInstance | Where-Object {$_.Default -eq $true}).ServerInstance
                $ManagementServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ManagementServicesPort']").Attributes["value"].Value
                $ClientServicesPort = $InstanceSettings.DocumentElement.appSettings.SelectSingleNode("add[@key='ClientServicesPort']").Attributes["value"].Value

                New-NAVServerInstance `
                    -ServerInstance $ServerInstance `
                    -ManagementServicesPort $ManagementServicesPort `
                    -ClientServicesPort $ClientServicesPort `
                    -ServiceAccount NetworkService 
                Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName SOAPServicesSSLEnabled -KeyValue true
                Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName ODataServicesSSLEnabled -KeyValue true
                Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName SOAPServicesEnabled -KeyValue false
                Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName ODataServicesEnabled -KeyValue false
                UnLoad-InstanceAdminTools
            } -ArgumentList $ServerInstance -ErrorAction Stop        


    }    
}