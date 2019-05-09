if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    if ($SetupParameters.testCompanyName -and $SetupParameters.testCompanyName -gt "") {
        $companyName = $SetupParameters.testCompanyName
    } else {
        $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
    }
    if ($SetupParameters.testCodeunitId -and $SetupParameters.testCodeunitId -gt "") {
        $CodeunitId = $SetupParameters.testCodeunitId
    } else {
        $CodeunitId = 130402
    }

    Load-InstanceAdminTools -SetupParameters $SetupParameters                        
    $Users = Get-NAVServerUser -ServerInstance $BranchSettings.instanceName
    if ($Users) {
        if (!($Users | Where-Object -Property UserName -imatch "${env:USERNAME}")) {
            Write-Host "Creating User ${env:USERNAME}..."
            New-NAVServerUser -ServerInstance $BranchSettings.instanceName -WindowsAccount $env:USERNAME 
            New-NAVServerUserPermissionSet -ServerInstance $BranchSettings.instanceName -WindowsAccount $env:USERNAME  -PermissionSetId 'SUPER'
        } else {
            Write-Host "User ${env:USERNAME}  already exists."
        }
    }

    $startDate = Get-Date 
    Write-Host "Starting Test Codeunit..."
    Invoke-NAVCodeunit -ServerInstance $BranchSettings.instanceName -CodeunitId $CodeunitId -CompanyName $companyName
    UnLoad-InstanceAdminTools

    $ResultTableName = Get-DatabaseTableName -CompanyName $companyName -TableName 'CAL Test Result'
    $Command = "select count([No_]) as [No. of Tests],CASE [Result] WHEN 0 THEN 'Passed' WHEN 1 THEN 'Failed' WHEN 2 THEN 'Inconclusive' ELSE 'Incomplete' END as [Result] from [$ResultTableName] group by [Result]"
    $SqlResult = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $Command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword  
    Write-Host ''
    Write-Host "Results..."
    Write-Host ''
    $SqlResult | Format-Table
    $endDate = Get-Date
    Write-Host ''
    Write-Host "Started $startDate, ended $endDate, duration $(($endDate - $StartDate).ToString('g'))"
}