if ($BranchSettings.dockerContainerId -gt "") {    
    $Session = New-DockerSession -DockerContainerId $BranchSettings.dockerContainerId
    Load-DockerInstanceAdminTools -Session $Session
    Invoke-Command -Session $Session -ScriptBlock {
        param([string]$ServerInstance)
        $CompanyName=(Get-NAVCompany -ServerInstance $ServerInstance).CompanyName
        if ($CompanyName -notmatch "CRONUS") {
            $CompanyName = "My Test Company"
            Write-Host "Initializing company ${CompanyName}..."
            Get-NAVCompany -ServerInstance $ServerInstance | Remove-NAVCompany -ServerInstance $ServerInstance -Force
            New-NAVCompany -ServerInstance $ServerInstance -CompanyName $CompanyName -EvaluationCompany        
        }
        New-NAVServerUser -WindowsAccount $env:USERNAME -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
        New-NAVServerUserPermissionSet -WindowsAccount $env:USERNAME -PermissionSetId SUPER -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
        Invoke-NAVCodeunit -CompanyName $CompanyName -CodeunitId 2 -Language en-US -ServerInstance $ServerInstance -Force            
    } -ArgumentList $BranchSettings.instanceName
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters 
    $CompanyName=(Get-NAVCompany -ServerInstance $ServerInstance).CompanyName
    if ($CompanyName -notmatch "CRONUS") {
        $CompanyName = "My Test Company"
        Write-Host "Initializing company ${CompanyName}..."
        Get-NAVCompany -ServerInstance $ServerInstance | Remove-NAVCompany -ServerInstance $ServerInstance -Force
        New-NAVCompany -ServerInstance $ServerInstance -CompanyName $CompanyName -EvaluationCompany        
    }
    New-NAVServerUser -WindowsAccount $env:USERNAME -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
    New-NAVServerUserPermissionSet -WindowsAccount $env:USERNAME -PermissionSetId SUPER -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
    Invoke-NAVCodeunit -CompanyName $CompanyName -CodeunitId 2 -Language en-US -ServerInstance $ServerInstance -Force            

}
