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
        [string[]]$CompanyNames,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$CustomDatabase,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $false)]
        [switch]$ShowProgress

    )

    if ($CustomDatabase) {
        Get-SQLCommandResult -Server $DatabaseServer -Database $CustomDatabase -Command "IF not EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'Object') CREATE TABLE [dbo].[Object]([Name] [varchar](250) NOT NULL,[MetaData] [varchar](max) NULL,[Company] [varchar](30) NULL) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]"
    }

    if ($ExportPath) {
        foreach ($CompanyName in $CompanyNames) {
            $CompanyExportPath = Join-Path $ExportPath ([RegEx]::Replace($CompanyName, "[{0}]" -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), ''))
            New-Item -Path $CompanyExportPath -ItemType Directory -ErrorAction SilentlyContinue| Out-Null
        }
    }

    $tables = Get-NAVTenantTableNos -TenantDatabase $TenantDatabase -DatabaseServer $DatabaseServer -NosOnly
    $step = 0
    foreach ($table in $tables) {
        Write-Verbose -Message "Table $($table.TableId)"
        if ($ShowProgress) {
            $step += 1
            Write-Progress -Activity "Exporting Custom Data" -CurrentOperation "Table $($table.TableId)" -PercentComplete ($Step / $tables.count * 100)
        }
        Get-NAVUpgradeTableData -TenantDatabase $TenantDatabase -ApplicationDatabase $ApplicationDatabase -DatabaseServer $DatabaseServer -TableId $table.TableId -ExportPath $ExportPath -CompanyNames $CompanyNames -CustomDatabase $CustomDatabase                
        
    }
}

