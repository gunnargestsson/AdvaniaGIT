Function Get-NAVClickOnceApplicationIcon {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {
        $RemoteConfig = Get-NAVRemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {
                Write-Host "Downloading Application Icon from $($RemoteComputer.HostName)..."
                $Session = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                [Byte[]]$CompressedIconData = Invoke-Command -Session $Session -ScriptBlock `
                    {
                        Param([PSObject]$HostConfig)                                                
                        $NAVDVDFilePath = $HostConfig.NAVDVDPath
                        $NAVIconPath = Join-Path $NAVDVDFilePath "ClickOnceInstallerTools\Program Files\Microsoft Dynamics NAV\$($SetupParameters.mainVersion)\ClickOnce Installer Tools\TemplateFiles\Deployment\ApplicationFiles\Icon.ico"
                        if (Test-Path $NAVIconPath) {
                            $ZipFile = Join-Path $Env:TEMP "$(New-Guid).zip"
                            Compress-Archive -Path $NAVIconPath -DestinationPath $ZipFile                            
                            $CompressedIconData = [Byte[]] (Get-Content -Path $ZipFile -Encoding Byte) 
                            Remove-Item -Path $ZipFile -Force -ErrorAction SilentlyContinue
                        } else {
                            Throw "NAV Application Icon not found on $($HostConfig.FQDN)!"
                        }
                        Return $CompressedIconData                        
                    } -ArgumentList $RemoteComputer -ErrorAction Stop
                Remove-PSSession -Session $Session

                $ZipFile = Join-Path $Env:TEMP "$(New-Guid).zip"
                Set-Content -Path $ZipFile -Value $CompressedIconData -Encoding Byte

                $IconFolder = Join-Path $Env:TEMP "$(New-Guid)"
                Expand-Archive -Path $ZipFile -DestinationPath $IconFolder

                $IconFilePath = Join-Path $IconFolder "icon.ico"
                Remove-Item -Path $ZipFile -Force -ErrorAction SilentlyContinue
               
                return $IconFilePath
            }
        }
    }    
}