function Clear-BranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$BranchId
    )
    $LocalSetupParameters = New-Object -TypeName PSObject
    $LocalSetupParameters | Add-Member -MemberType NoteProperty -Name branchId -Value $BranchId
    $LocalBranchSettings = Get-BranchSettings -SetupParameters $LocalSetupParameters 
    $ReturnedBranchSettings = Get-BranchSettings -SetupParameters $LocalSetupParameters 
    $LocalBranchSettings.databaseInstance = ""
    $LocalBranchSettings.databaseName = ""
    $LocalBranchSettings.databaseServer = ""
    $LocalBranchSettings.instanceServer = ""
    $LocalBranchSettings.instanceName = ""
    $LocalBranchSettings.dockerContainerName = ""
    $LocalBranchSettings.dockerContainerId = ""
    $LocalBranchSettings.dockerContainerIp = ""
    $LocalBranchSettings.projectName = ""
    $BlankBranchSettings = Update-BranchSettings -BranchSettings $LocalBranchSettings -Clear  
    Return $ReturnedBranchSettings
}
