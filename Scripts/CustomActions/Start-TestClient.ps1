$ClientSettings = Prepare-NAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings 

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

$command = "SELECT TOP 1 [Profile ID] FROM [dbo].[Profile]  WHERE [Role Center ID] = 9006"
$result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $Command
Write-Host "Profile found $($result.'Profile ID')..."

$params = @()
$params += @("-consolemode -showNavigationPage:0 -language:1033 -profile:`"$($result.'Profile ID')`" -settings:`"$($ClientSettings.Config)`" `"dynamicsnav:////$companyName/RunCodeunit?Codeunit=$CodeunitId`"")
$startDate = Get-Date 
Write-Host "Running: `"$($ClientSettings.Client)`" $params" -ForegroundColor Green
Start-Process -FilePath $ClientSettings.Client -ArgumentList $params -Wait

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
