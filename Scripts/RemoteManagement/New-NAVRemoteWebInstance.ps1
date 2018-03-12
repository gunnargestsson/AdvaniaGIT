Function New-NAVRemoteWebInstance {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ClientSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$TestDeploymentServer
    )
    PROCESS 
    {
        # Create the Webclient Site
        
                
        $Language = $SelectedInstance.TenantList[0].Language
        $Result = Invoke-Command -Session $Session -ScriptBlock `
            {
                Param([PSObject]$SelectedInstance, [PSObject]$ClientSettings, [String]$DnsIdentity, [string]$TestDeploymentServer)
                Load-InstanceAdminTools -SetupParameters $SetupParameters
                Write-Host "Creating Web Client Site for $($SelectedInstance.ServerInstance)..."
                Import-Module WebAdministration
                if ([int]$SetupParameters.mainVersion -ge 110) {
                    New-NAVWebServerInstance `
                        -ClientServicesCredentialType $SelectedInstance.ClientServicesCredentialType `
                        -ClientServicesPort $SelectedInstance.ClientServicesPort `
                        -DnsIdentity $DnsIdentity `
                        -Server localhost `
                        -ServerInstance $SelectedInstance.ServerInstance `
                        -WebServerInstance $SelectedInstance.ServerInstance `
                } else {
                    New-NAVWebServerInstance `
                        -ClientServicesCredentialType $SelectedInstance.ClientServicesCredentialType `
                        -ClientServicesPort $SelectedInstance.ClientServicesPort `
                        -RegionFormat $Language `
                        -Language $Language `
                        -DnsIdentity $DnsIdentity `
                        -Server localhost `
                        -ServerInstance $SelectedInstance.ServerInstance `
                        -WebServerInstance $SelectedInstance.ServerInstance
                }
                $navSettings = Join-Path (Join-Path "C:\inetpub\wwwroot" $SelectedInstance.ServerInstance) "navsettings.json"
                if (Test-Path $navSettings) {
                    $navWebClientSettings = (Get-Content -Path $navSettings -Encoding UTF8 | Out-String | ConvertFrom-Json).NAVWebSettings
                    $Properties = Foreach ($ClientSetting in $ClientSettings) { Get-Member -InputObject $ClientSetting -MemberType NoteProperty}
                    Foreach ($Property in $Properties.Name) {
                        $KeyValue = $ExecutionContext.InvokeCommand.ExpandString($ClientSettings.$($Property))
                        $navWebClientSettings | Add-Member -MemberType NoteProperty -Name $Property -Value $KeyValue -Force
                    }
                    $newWebClientSettings = New-Object -ItemType PSObject 
                    $newWebClientSettings | Add-Member -MemberType NoteProperty -Name NAVWebSettings -Value @()
                    $newWebClientSettings.NAVWebSettings = $navWebClientSettings
                    Write-Host ( $newWebClientSettings | ConvertTo-Json )
                    #Set-Content -Path $navSettings -Encoding UTF8 -Value ( $newWebClientSettings | ConvertTo-Json )
                } else {
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
                }

                if ($SelectedInstance.AppIdUri -gt "") {
                    $AzureADDomain = $SelectedInstance.ClientServicesFederationMetadataLocation.split("/").GetValue(3)
                    Write-Host "Creating Web Client Site for $($SelectedInstance.ServerInstance)365..."
                    if ([int]$SetupParameters.mainVersion -ge 110) {
                        New-NAVWebServerInstance `
                            -ClientServicesCredentialType AccessControlService `
                            -ClientServicesPort $SelectedInstance.ClientServicesPort `
                            -DnsIdentity $DnsIdentity `
                            -Server localhost `
                            -ServerInstance $SelectedInstance.ServerInstance `
                            -WebServerInstance "$($SelectedInstance.ServerInstance)365" `
                            -AcsUri "https://login.windows.net/common/wsfed?wa=wsignin1.0%26wtrealm=$($SelectedInstance.AppIdUri)%26wreply=$($SelectedInstance.PublicWebBaseUrl)365/WebClient/SignIn.aspx"
                    } else {
                        New-NAVWebServerInstance `
                            -ClientServicesCredentialType AccessControlService `
                            -ClientServicesPort $SelectedInstance.ClientServicesPort `
                            -RegionFormat $Language `
                            -Language $Language `
                            -DnsIdentity $DnsIdentity `
                            -Server localhost `
                            -ServerInstance $SelectedInstance.ServerInstance `
                            -WebServerInstance "$($SelectedInstance.ServerInstance)365" `
                            -AcsUri "https://login.windows.net/common/wsfed?wa=wsignin1.0%26wtrealm=$($SelectedInstance.AppIdUri)%26wreply=$($SelectedInstance.PublicWebBaseUrl)365/WebClient/SignIn.aspx"
                    }

                    $navSettings = Join-Path (Join-Path "C:\inetpub\wwwroot" "$($SelectedInstance.ServerInstance)365") "navsettings.json"
                    if (Test-Path $navSettings) {
                    } else {
                        $WebConfigPath = Get-ChildItem -Path (Join-Path "C:\inetpub\wwwroot" "$($SelectedInstance.ServerInstance)365") -Filter "web.config"
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
                    }
                }

                if (![System.String]::IsNullOrEmpty($TestDeploymentServer)) {
                    Write-Host "Creating Web Client Site for $($SelectedInstance.ServerInstance)Test..."
                    if ([int]$SetupParameters.mainVersion -ge 110) {
                        New-NAVWebServerInstance `
                            -ClientServicesCredentialType $SelectedInstance.ClientServicesCredentialType `
                            -ClientServicesPort $SelectedInstance.ClientServicesPort `
                            -DnsIdentity $DnsIdentity `
                            -Server $TestDeploymentServer `
                            -ServerInstance $SelectedInstance.ServerInstance `
                            -WebServerInstance "$($SelectedInstance.ServerInstance)Test"
                    } else {
                        New-NAVWebServerInstance `
                            -ClientServicesCredentialType $SelectedInstance.ClientServicesCredentialType `
                            -ClientServicesPort $SelectedInstance.ClientServicesPort `
                            -RegionFormat $Language `
                            -Language $Language `
                            -DnsIdentity $DnsIdentity `
                            -Server $TestDeploymentServer `
                            -ServerInstance $SelectedInstance.ServerInstance `
                            -WebServerInstance "$($SelectedInstance.ServerInstance)Test"
                    }

                    $navSettings = Join-Path (Join-Path "C:\inetpub\wwwroot" "$($SelectedInstance.ServerInstance)Test") "navsettings.json"
                    if (Test-Path $navSettings) {
                    } else {
                        $WebConfigPath = Get-ChildItem -Path (Join-Path "C:\inetpub\wwwroot" "$($SelectedInstance.ServerInstance)Test") -Filter "web.config"
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
                    }
                }


                UnLoad-InstanceAdminTools

            } -ArgumentList ($SelectedInstance, $ClientSettings, (Get-NAVDnsIdentity -SelectedInstance $SelectedInstance), $TestDeploymentServer) -ErrorAction Stop        
    }
}