Function Load-NAVRemoteInstanceMenu {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$RemoteConfig,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DeploymentName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$IncludeAllHosts
    )
    
    $instanceNo = 1
    $Instances = @()
    $Hosts = ($RemoteConfig.Remotes | Where-Object -Property Deployment -EQ $DeploymentName).Hosts
    Foreach ($Host in $Hosts) {
        $Hostname = $Host.Hostname
        $FQDN = $Host.FQDN
        $Roles = $Host.Roles
        if ($Roles -like "*Client*" -or $Roles -like "*NAS*") {
            Write-Verbose "Connect to $FQDN..."
            $Session = Create-NAVRemoteSession -Credential $Credential -HostName $FQDN 
            $hostInstances = Get-NAVRemoteInstances -Session $Session
            foreach ($instance in $hostInstances) {
                if (!($Instances | Where-Object -Property ServerInstance -EQ $instance.ServerInstance) -or $IncludeAllHosts) {                   
                    $instance | Add-Member -MemberType NoteProperty -Name No -Value $instanceNo
                    $instance | Add-Member -MemberType NoteProperty -Name HostName -Value $HostName
                    $instanceNo ++
                    $Instances += $instance
                }
            }            
            Remove-PSSession -Session $Session
        }
    }
    return $Instances    
    
}