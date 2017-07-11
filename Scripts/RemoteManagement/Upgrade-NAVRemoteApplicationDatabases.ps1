Function Upgrade-NAVRemoteApplicationDatabases {
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstances,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$UserName, 
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$Password
    )
    PROCESS 
    {
        Invoke-Command -Session $Session -ScriptBlock `
            {
                param([PSObject]$ServerInstances, [String]$UserName, [String]$Password)
                if (Test-Path (Join-Path $SetupParameters.navIdePath "finsql.exe")) {
                    Foreach ($ServerInstance in $ServerInstances) {
                        Write-Host "Upgrading database $($ServerInstance.DatabaseName)..."                   
                        $BranchSettings = New-Object -TypeName PSObject 
                        $BranchSettings | Add-Member -MemberType NoteProperty -Name databaseInstance -Value $SetupParameters.DatabaseInstance
                        $BranchSettings | Add-Member -MemberType NoteProperty -Name databaseServer -Value $ServerInstance.DatabaseServer
                        $BranchSettings | Add-Member -MemberType NoteProperty -Name databaseName -Value $ServerInstance.DatabaseName
                        $BranchSettings | Add-Member -MemberType NoteProperty -Name instanceName -Value ""
                        Invoke-NAVDatabaseConversion -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Username $UserName -Password $Password
                    }               
                }
            } -ArgumentList ($ServerInstances, $UserName, $Password)
    }    
}