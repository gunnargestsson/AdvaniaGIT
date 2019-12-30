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
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath


    )

    foreach ($table in (Get-NAVTenantTableNos -TenantDatabase $TenantDatabase -DatabaseServer $DatabaseServer)) {
        Write-Verbose -Message "Table $($table.TableId)"
        $ExportFilePath = Join-Path $ExportPath "Table$($table.TableId).xml"
        $Xml = Get-NAVUpgradeTableData -TenantDatabase $TenantDatabase -ApplicationDatabase $ApplicationDatabase -DatabaseServer $DatabaseServer -TableId $table.TableId -CompanyName $CompanyName
        if (![String]::IsNullOrEmpty($Xml)) {
            $Xml = Repair-XmlString -inXML $Xml 
            Set-Content -Value $Xml -Path $ExportFilePath -Encoding UTF8 -Force
            Write-Verbose -Message "Exported"
        }
    }

}
