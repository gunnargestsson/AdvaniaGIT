Function Start-NAVRemoteDevelopment {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    $RemoteSetupParameters = New-Object -TypeName PSObject
    $RemoteSetupParameters | Add-Member -MemberType NoteProperty -Name navVersion -Value $SelectedInstance.Version
    $RemoteSetupParameters | Add-Member -MemberType NoteProperty -Name mainVersion -Value (($SelectedInstance.Version).Split('.').GetValue(0) + ($SelectedInstance.Version).Split('.').GetValue(1))
    $navIdePath = Get-NAVClientPath -SetupParameters $RemoteSetupParameters
    $finsqlexe = (Join-Path $navIdePath 'finsql.exe')
    $IdFile = $SelectedInstance.DatabaseName
    $BranchSettings = New-Object -TypeName PSObject
    $BranchSettings | Add-Member -MemberType NoteProperty -Name databaseInstance -Value $SelectedInstance.DatabaseInstance
    $BranchSettings | Add-Member -MemberType NoteProperty -Name databaseServer -Value $SelectedInstance.DatabaseServer
    $BranchSettings | Add-Member -MemberType NoteProperty -Name databaseName -Value $SelectedInstance.DatabaseName
    $BranchSettings | Add-Member -MemberType NoteProperty -Name instanceName -Value $SelectedInstance.ServerInstance
    $params="database=`"$($BranchSettings.databaseName)`",servername=`"$(Get-DatabaseServer -BranchSettings $BranchSettings)`",ID=`"$($IdFile)`",NTAuthentication=No"
    Start-Process -FilePath $finsqlexe -ArgumentList $params 
}