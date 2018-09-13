Function Start-NAVRemoteDevelopment {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    
    $RemoteConfig = Get-NAVRemoteConfig
    $DBAdmin = Get-NAVUserPasswordObject -Usage "DBUserPasswordID"
    if ($DBAdmin.UserName -gt "" -and $DBAdmin.Password -gt "") {
        $Credential = New-Object System.Management.Automation.PSCredential($DBAdmin.UserName, (ConvertTo-SecureString $DBAdmin.Password -AsPlainText -Force))
    } else {
        $Credential = Get-Credential -Message "Remote Login to FinSql" -ErrorAction Stop
        $DBAdmin.UserName = $Credential.UserName
        $DBAdmin.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))
    }    

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
    $params="database=`"$($BranchSettings.databaseName)`",servername=`"$(Get-DatabaseServer -BranchSettings $BranchSettings)`",ID=`"$($IdFile)`",NTAuthentication=No,username=$($DBAdmin.UserName),password=$($DBAdmin.Password)"
    Start-Process -FilePath $finsqlexe -ArgumentList $params 
}