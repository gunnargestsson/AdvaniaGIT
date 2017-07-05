Function Load-NAVRemoteInstanceSessionsMenu {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )

    $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName
    $NAVsessionNo = 1
    $NAVsessions = @()
    foreach ($NAVsession in (Get-NAVRemoteInstanceTenantSessions -Session $Session -SelectedInstance $SelectedInstance -SelectedTenant $SelectedTenant)) {
        $NAVsession | Add-Member -MemberType NoteProperty -Name No -Value $NAVsessionNo
        $NAVsessionNo ++
        $NAVsessions += $NAVsession
    }
    Remove-PSSession $Session
    return $NAVsessions
}