function Load-StartMenu
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$RemoteConfig
    )
    $menuItems = @()
    $deploymentNo = 1
    foreach ($deployment in $RemoteConfig.Remotes) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $deploymentNo
        $menuItem | Add-Member -MemberType NoteProperty -Name Deployment -Value $deployment.Deployment
        $menuItem | Add-Member -MemberType NoteProperty -Name Description -Value $deployment.Description
        $menuItems += $menuItem
        $deploymentNo ++
    }    
    Return $menuItems
}

