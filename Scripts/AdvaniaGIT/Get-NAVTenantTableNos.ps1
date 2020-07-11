function Get-NAVTenantTableNos
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [string]$TenantDatabase,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$DatabaseServer = 'localhost',
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [switch]$NosOnly

    )

    if ($NosOnly) {
        Get-SQLCommandResult -Server $DatabaseServer -Database $TenantDatabase -Command "SELECT [Object ID] As TableID FROM [Object Metadata] WHERE [Object Type] = 1 AND [Object ID] < 2000000000"
    } else {
        Get-SQLCommandResult -Server $DatabaseServer -Database $TenantDatabase -Command "SELECT [Object ID] As TableID, Name FROM [Object Metadata Snapshot] WHERE [Object Type] = 1 AND [Object ID] < 2000000000"
    }
}

