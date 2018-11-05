function Get-UncompiledObjectsCount
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    
    
    $command = "SELECT COUNT([ID]) AS NoOfObjects FROM [dbo].[Object] WHERE [Compiled] = 0"
    $result = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $Command
    Write-Host "Uncompiled objects: $($result.NoOfObjects)"
    return $result.NoOfObjects
}
