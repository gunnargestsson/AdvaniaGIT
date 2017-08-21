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
    $LocalBranchSettings.instanceName = ""
    if ($LocalBranchSettings.dockerHostName) {
        $LocalBranchSettings.dockerHostName = ""
    } else {
        $LocalBranchSettings | Add-Member -MemberType NoteProperty -Name dockerHostName -Value ""
    }
    $BlankBranchSettings = Update-BranchSettings -BranchSettings $LocalBranchSettings    
    Return $ReturnedBranchSettings
}
