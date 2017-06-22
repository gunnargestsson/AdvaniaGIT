Function New-NAVRemoteClickOnceSite {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName
    )
    PROCESS 
    {
        if ($SelectedTenant.CustomerName -eq "") {
            Write-Host -ForegroundColor Red "Customer Name not configured.  Configure with Tenant Settings."
            break
        } elseif ($SelectedTenant.ClickOnceHost -eq "") {
            Write-Host -ForegroundColor Red "ClickOnce Host not configured.  Configure with Tenant Settings."
            break
        } elseif (!(Resolve-DnsName -Name $SelectedTenant.ClickOnceHost -ErrorAction SilentlyContinue)) {
            Write-Host -ForegroundColor Red "Host $($SelectedTenant.ClickOnceHost) not found in Dns!"
            break
        }
        Write-Host "Building ClickOnce Site for $($SelectedTenant.CustomerName)..."

        $RemoteConfig = Get-RemoteConfig
        $Remotes = $RemoteConfig.Remotes | Where-Object -Property Deployment -eq $DeploymentName
        Foreach ($RemoteComputer in $Remotes.Hosts) {
            $Roles = $RemoteComputer.Roles
            if ($Roles -like "*ClickOnce*") {

                Write-Host "Updating $($RemoteComputer.HostName)..."
                if ($Session.ComputerName -eq $RemoteComputer.FQDN) {
                    $RemoteSession = $Session
                } else {
                    $RemoteSession = New-NAVRemoteSession -Credential $Credential -HostName $RemoteComputer.FQDN 
                }        
                Invoke-Command -Session $RemoteSession -ScriptBlock `
                    {
                        if (!(Test-Path (Join-Path $env:SystemDrive "inetpub\wwwroot\ClickOnce"))) {
                            New-Item -Path (Join-Path $env:SystemDrive "inetpub\wwwroot\ClickOnce") -ItemType Directory | Out-Null
                        }
                    } 



                if ($Session.ComputerName -ne $RemoteSession.ComputerName) { Remove-PSSession -Session $RemoteSession }
            }
        }
        Return $Database

    }
}