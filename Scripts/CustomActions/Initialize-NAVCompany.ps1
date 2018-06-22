if ($BranchSettings.dockerContainerId -gt "") {    
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Load-DockerInstanceAdminTools -Session $Session
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ServerInstance)
        Write-Host "Initializing company 'My Test Company'..."
        Get-NAVCompany -ServerInstance $ServerInstance | Remove-NAVCompany -ServerInstance $ServerInstance -Force
        New-NAVCompany -ServerInstance $ServerInstance -CompanyName "My Test Company" -EvaluationCompany        
        New-NAVServerUser -WindowsAccount $env:USERNAME -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
        New-NAVServerUserPermissionSet -WindowsAccount $env:USERNAME -PermissionSetId SUPER -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
        Invoke-NAVCodeunit -CompanyName "My Test Company" -CodeunitId 2 -Language en-US -ServerInstance $ServerInstance -Force            
    } -ArgumentList $BranchSettings.instanceName

} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters 
    Write-Host "Initializing company 'My Test Company'..."
    Get-NAVCompany -ServerInstance $ServerInstance | Remove-NAVCompany -ServerInstance $ServerInstance -Force
    New-NAVCompany -ServerInstance $ServerInstance -CompanyName "My Test Company" -EvaluationCompany        
    Invoke-NAVCodeunit -CompanyName "My Test Company" -CodeunitId 2 -Language en-US -ServerInstance $ServerInstance -Force                
}
