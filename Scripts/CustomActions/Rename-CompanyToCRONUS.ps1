
if ($BranchSettings.dockerContainerId -gt "") {
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Load-DockerInstanceAdminTools -Session $Session
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ServerInstance)
        $CompanyName = (Get-NAVCompany $ServerInstance)[0]
        if ($CompanyName -cnotmatch "CRONUS") {
            Write-Host "Renaming compnany ${CompanyName} to CRONUS ${CompanyName}..."
            Rename-NAVCompany -CompanyName $CompanyName -NewCompanyName "CRONUS ${CompanyName}" -ServerInstance $ServerInstance -Force
        }            
    } -ArgumentList $BranchSettings.instanceName

} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters 
    $CompanyName = (Get-NAVCompany $BranchSettings.instanceName)[0]
    if ($CompanyName -cnotmatch "CRONUS") {
        Write-Host "Renaming compnany ${CompanyName} to CRONUS ${CompanyName}..."
        Rename-NAVCompany -CompanyName $CompanyName -NewCompanyName "CRONUS ${CompanyName}" -ServerInstance $BranchSettings.instanceName -Force
    }            
}
