Function Load-NAVRemoteInstanceTenantUsersMenu {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedTenant
    )

    $userNo = 1
    $Users = @()
    foreach ($User in (Get-NAVRemoteInstanceTenantUsers -Session $Session -SelectedTenant $SelectedTenant)) {
        $User | Add-Member -MemberType NoteProperty -Name No -Value $userNo
        $userNo ++
        $Users += $user
    }
    return $Users
}