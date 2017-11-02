Function New-NAVRemoteBranchSettingsObject
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSetup
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        param([PSObject]$BranchSetup)
        
        # Set Branch Settings
        $BranchSettings = New-Object PSObject
        $BranchSettings | Add-Member "databaseName" ""
        $BranchSettings | Add-Member "branchId" $BranchSetup.branchId
        $BranchSettings | Add-Member "managementServicesPort" ""
        $BranchSettings | Add-Member "projectName" $BranchSetup.projectName
        $BranchSettings | Add-Member "instanceName" ""
        $BranchSettings | Add-Member "databaseInstance" ""
        $BranchSettings | Add-Member "databaseServer" ""
        $BranchSettings | Add-Member "clientServicesPort" ""
        $BranchSettings | Add-Member "developerServicesPort" ""
        $BranchSettings | Add-Member "dockerContainerId" ""
        $BranchSettings | Add-Member "dockerContainerName" ""

        $SetupParameters = Combine-Settings $BranchSetup $SetupParameters

    } -ArgumentList $BranchSetup

}