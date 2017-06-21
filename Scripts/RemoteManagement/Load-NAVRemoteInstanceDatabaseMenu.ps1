Function Load-NAVRemoteInstanceDatabaseMenu {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )

    $Database = New-DatabaseObject `
        -DatabaseName $SelectedInstance.DatabaseName `
        -DatabaseServerName $SelectedInstance.DatabaseServer `
        -DatabaseInstanceName $SelectedInstance.DatabaseInstance `
        -DatabaseUserName $SelectedInstance.DatabaseUserName

    return $Database
}