if ($BranchSettings.dockerContainerId -gt "") {    
    Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -ScriptBlock {
        param([string]$ServerInstance)
        $AdminTool = Get-Item 'C:\Program Files\Microsoft Dynamics NAV\*\Service\NavAdminTool.ps1'
        if ($AdminTool) {
            Import-Module $AdminTool.FullName -DisableNameChecking
        } else {
            $AdminTool = Get-Item 'C:\Program Files\Microsoft Dynamics 365 Business Central\*\Service\NavAdminTool.ps1'
            Import-Module $AdminTool.FullName -DisableNameChecking
        }
        $CompanyList = Get-NAVCompany -ServerInstance $ServerInstance
        if ($CompanyList -eq $null) {
            $CompanyName = "My Test Company"
            Write-Host "Initializing company ${CompanyName}..."
            New-NAVCompany -ServerInstance $ServerInstance -CompanyName $CompanyName -EvaluationCompany        
        } elseif ($CompanyList.CompanyName -notmatch "CRONUS") {
            Get-NAVCompany -ServerInstance $ServerInstance | Remove-NAVCompany -ServerInstance $ServerInstance -Force
            $CompanyName = "My Test Company"
            Write-Host "Initializing company ${CompanyName}..."
            New-NAVCompany -ServerInstance $ServerInstance -CompanyName $CompanyName -EvaluationCompany        
        } else {
            foreach ($Company in $CompanyList) { $CompanyName = $Company.CompanyName }
        }
        New-NAVServerUser -WindowsAccount $env:USERNAME -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
        New-NAVServerUserPermissionSet -WindowsAccount $env:USERNAME -PermissionSetId SUPER -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
        Invoke-NAVCodeunit -CompanyName $CompanyName -CodeunitId 2 -Language en-US -ServerInstance $ServerInstance -Force            
    } -ArgumentList $BranchSettings.instanceName
} else {    
    Load-InstanceAdminTools -SetupParameters $SetupParameters 
    $CompanyList = Get-NAVCompany -ServerInstance $ServerInstance
    if ($CompanyList -eq $null) {
        $CompanyName = "My Test Company"
        Write-Host "Initializing company ${CompanyName}..."
        New-NAVCompany -ServerInstance $ServerInstance -CompanyName $CompanyName -EvaluationCompany        
    } elseif ($CompanyList.CompanyName -notmatch "CRONUS") {
        Get-NAVCompany -ServerInstance $ServerInstance | Remove-NAVCompany -ServerInstance $ServerInstance -Force
        $CompanyName = "My Test Company"
        Write-Host "Initializing company ${CompanyName}..."
        New-NAVCompany -ServerInstance $ServerInstance -CompanyName $CompanyName -EvaluationCompany        
    } else {
        foreach ($Company in $CompanyList) { $CompanyName = $Company.CompanyName }
    }
    New-NAVServerUser -WindowsAccount $env:USERNAME -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
    New-NAVServerUserPermissionSet -WindowsAccount $env:USERNAME -PermissionSetId SUPER -ServerInstance $ServerInstance -ErrorAction SilentlyContinue
    Invoke-NAVCodeunit -CompanyName $CompanyName -CodeunitId 2 -Language en-US -ServerInstance $ServerInstance -Force            

}
