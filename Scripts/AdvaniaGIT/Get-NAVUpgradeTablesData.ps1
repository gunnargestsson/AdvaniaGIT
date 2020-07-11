function Get-NAVUpgradeTablesData
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [string]$TenantDatabase,
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [string]$ApplicationDatabase,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$DatabaseServer = 'localhost',
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [string]$CompanyName,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$CustomDatabase

    )

    if ($CustomDatabase) {
        Get-SQLCommandResult -Server $DatabaseServer -Database $CustomDatabase -Command "IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'Object') CREATE TABLE [dbo].[Object]([Name] [varchar](250) NOT NULL,[MetaData] [varchar](max) NULL,[Company] [varchar](30) NULL) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]"
    }

    foreach ($table in (Get-NAVTenantTableNos -TenantDatabase $TenantDatabase -DatabaseServer $DatabaseServer -NosOnly)) {
        Write-Verbose -Message "Table $($table.TableId)"
        $Xml = Get-NAVUpgradeTableData -TenantDatabase $TenantDatabase -ApplicationDatabase $ApplicationDatabase -DatabaseServer $DatabaseServer -TableId $table.TableId -CompanyName $CompanyName -CustomDatabase $CustomDatabase                
        if (![String]::IsNullOrEmpty($Xml)) {
            if ($ExportPath) {
                $ExportFilePath = Join-Path $ExportPath "Table$($table.TableId).xml"        
                Set-Content -Value $Xml -Path $ExportFilePath -Encoding UTF8 -Force
            }
            Write-Verbose -Message "Exported"
        }
    }
}
