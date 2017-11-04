Function Start-NAVRemoteUnitTestsOnDockerContainer
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        $Session = New-DockerSession -DockerContainerId $BranchSettings.DockerContainerId
        Invoke-Command -Session $Session -ScriptBlock `
        {            
            Import-Module AdvaniaGIT | Out-Null
            $SetupParameters = Get-GITSettings
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters

            if ($SetupParameters.testCompanyName) {
                $companyName = $SetupParameters.testCompanyName
            } else {
                $companyName = Get-FirstCompanyName -SQLServer (Get-DatabaseServer -BranchSettings $BranchSettings) -SQLDb $BranchSettings.databaseName
            }
            $CompanyRegistrationNo = Initialize-NAVTestCompanyRegistrationNo -BranchSettings $BranchSettings -CompanyName $companyName
            #Prepare-NAVTestExecution -BranchSettings $BranchSettings -CompanyName $companyName 
            #Load-InstanceAdminTools -SetupParameters $SetupParameters
            #Initialize-NAVTestCompany -SetupParameters $SetupParameters -BranchSettings $BranchSettings
            #UnLoad-InstanceAdminTools

            $startDate = Get-Date
            Write-Host "Running Test Runner Page" -ForegroundColor Green
            Invoke-WebRequest -Uri "http://$($env:COMPUTERNAME)/nav/Default.aspx?page=130409" -OutFile (Join-Path $env:TEMP "TestResults.html") -TimeoutSec 0 -UseDefaultCredentials
            $ResultTableName = Get-DatabaseTableName -CompanyName $companyName -TableName 'CAL Test Result'
            $Command = "select count([No_]) as [No. of Tests],CASE [Result] WHEN 0 THEN 'Passed' WHEN 1 THEN 'Failed' WHEN 2 THEN 'Inconclusive' ELSE 'Incomplete' END as [Result] from [$ResultTableName] group by [Result]"
            $SqlResult = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $Command  
            Write-Host ''
            Write-Host "Results..."
            Write-Host ''
            $SqlResult | Format-Table
            $endDate = Get-Date
            Write-Host ''
            Write-Host "Started $startDate, ended $endDate, duration $(($endDate - $StartDate).ToString('g'))"

            Set-NAVCompanyInfoRegistrationNo -BranchSettings $BranchSettings -CompanyName $companyName -RegistrationNo $CompanyRegistrationNo

        }
        Remove-PSSession $Session
    }
}