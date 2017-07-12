Function New-NAVRemoteWebInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ClientSettings
    )
    PROCESS 
    {
        # Create the Webclient Site
        $Language = $SelectedInstance.TenantList[0].Language
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$SelectedInstance, [PSObject]$ClientSettings, [String]$DnsIdentity)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Write-Host "Creating Web Client Site for $($SelectedInstance.ServerInstance)..."
                New-NAVWebServerInstance `
                    -ClientServicesCredentialType $SelectedInstance.ClientServicesCredentialType `
                    -ClientServicesPort $SelectedInstance.ClientServicesPort `
                    -RegionFormat $Language `
                    -Language $Language `
                    -DnsIdentity $DnsIdentity `
                    -Server localhost `
                    -ServerInstance $SelectedInstance.ServerInstance `
                    -WebServerInstance $SelectedInstance.ServerInstance
                    $WebConfigPath = Get-ChildItem -Path (Join-Path "C:\inetpub\wwwroot" $SelectedInstance.ServerInstance) -Filter "web.config"
                    [xml]$WebConfig = Get-Content -Path $WebConfigPath.FullName -Encoding UTF8
                    $Properties = Foreach ($ClientSetting in $ClientSettings) { Get-Member -InputObject $ClientSetting -MemberType NoteProperty}
                    Foreach ($Property in $Properties.Name) {
                        $KeyValue = $ExecutionContext.InvokeCommand.ExpandString($ClientSettings.$($Property))                        
                        $XmlNode = $WebConfig.configuration.DynamicsNAVSettings.SelectSingleNode("add[@key='${Property}']")
                        if ($XmlNode) {
                            $XmlNode.SetAttribute("value",$Keyvalue)
                        } else {
                            $XmlNode = $WebConfig.CreateNode('element',"add",'')
                            $XmlNode.SetAttribute("key",$Property)
                            $XmlNode.SetAttribute("value",$Keyvalue)
                            $WebConfig.configuration.DynamicsNAVSettings.AppendChild($XmlNode)
                        }
                    }
                    $WebConfig.Save($WebConfigPath.FullName)
                UnLoad-InstanceAdminTools

            } -ArgumentList ($SelectedInstance, $ClientSettings, (Get-NAVDnsIdentity -SelectedInstance $SelectedInstance)) -ErrorAction Stop        
    }
}