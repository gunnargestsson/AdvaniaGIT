Function Prepare-NAVTestExecution
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$CompanyName,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [Switch]$OnlyFailingTests,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [Switch]$ForModifiedObjects,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [Switch]$TestExecutionContinuing,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$CodeunitIdFilter
    )   

    $command = "DELETE FROM [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Enabled Codeunit')]"
    Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null
    if ($OnlyFailingTests) {
        $command = "SELECT DISTINCT [Codeunit ID] FROM [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Result')] WHERE [Result]>0"
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | % {
          $command = "INSERT INTO [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Enabled Codeunit')] ([Test Codeunit ID]) VALUES($($_.'Codeunit ID'))"
          Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null
        }
        $command = "DELETE FROM [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Result')] WHERE [Result]>0"
        Write-Host "Retrying $(Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command) tests..."
    } elseif ($ForModifiedObjects) {
        $command = "SELECT DISTINCT [Test Codeunit ID] FROM [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Coverage Map')],[Object] WHERE [Modified] = 1 AND [Type] = [Object Type] AND [ID] = [Object ID]"
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | % {
          $command = "INSERT INTO [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Enabled Codeunit')] ([Test Codeunit ID]) VALUES($($_.'Test Codeunit ID'))"
          Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null
        }
    } else {
        # C/AL Test Codeunits
        if ([String]::IsNullOrEmpty($CodeunitIdFilter)) {
            $command = "SELECT [Object ID] FROM [dbo].[Object Metadata] WHERE [Object Type] = '5' AND [Object Subtype] = 'Test'"
        } else {
            $command = "SELECT [Object ID] FROM [dbo].[Object Metadata] WHERE [Object ID] $CodeunitIdFilter AND [Object Type] = '5' AND [Object Subtype] = 'Test'"
        }
        $Codeunits = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command
        # AL Test Codeunits
        if ([String]::IsNullOrEmpty($CodeunitIdFilter)) {
            $command = "SELECT [Object ID] FROM [dbo].[NAV App Object Metadata] WHERE [Object Type] = '5' AND [Object Subtype] = 'Test'"
        } else {
            $command = "SELECT [Object ID] FROM [dbo].[NAV App Object Metadata] WHERE [Object ID] $CodeunitIdFilter AND [Object Type] = '5' AND [Object Subtype] = 'Test'"
        }
        $Codeunits += Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command

        foreach ($Codeunit in $Codeunits) {
          $command = "INSERT INTO [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Enabled Codeunit')] ([Test Codeunit ID]) VALUES($($Codeunit.'Object ID'))"
          Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null
        }
    }
    if (!$TestExecutionContinuing) {
        Write-Host "Deleting previous test results..."
        $command = "DELETE FROM [$(Get-DatabaseTableName -CompanyName $CompanyName -TableName 'CAL Test Result')]"
        Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $command | Out-Null 
    }     
}