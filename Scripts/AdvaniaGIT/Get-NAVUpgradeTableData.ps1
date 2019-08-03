function Get-NAVUpgradeTableData
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
        [int]$TableId,
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [string]$CompanyName

    )

    $CreateSelectStatement = $false

    [xml]$TenantXml = Get-NAVTableMetaDataXml -DatabaseName $TenantDatabase -DatabaseServer $DatabaseServer -TableId $TableId -Snapshot
    [xml]$ApplicationXml = Get-NAVTableMetaDataXml -DatabaseName $ApplicationDatabase -DatabaseServer $DatabaseServer -TableId $TableId

    $ReplaceChars = '."\/%]['''
    $FieldsInSelect = @()
    $SelectFields = ""
    foreach ($field in ($TenantXml.MetaTable.Keys.FirstChild.Key).split(',')) {
        $FieldsInSelect += $field.substring(5)
    }

    foreach ($field in $TenantXml.MetaTable.Fields.Field) {
        if ($FieldsInSelect -contains $field.ID) {
            Write-Verbose -Message "Field $($field.ID) $($field.Name) is a primary key field"
        } elseif ($field.FieldClass -eq "Normal" -and $field.Enabled -eq "1") {
            $applicationField = $ApplicationXml.MetaTable.Fields.Field | Where-Object -Property ID -EQ $field.ID
            if ($applicationField) {                
                if ($applicationField.Datatype -ne $field.Datatype -or `
                    $applicationField.DataLength -lt $field.DataLength -or `
                    $applicationField.Enabled -ne $field.Enabled -or `
                    $applicationField.FieldClass -ne $field.FieldClass -or `
                    $applicationField.AutoIncrement -ne $field.AutoIncrement -or `
                    $applicationField.ExtendedDatatype -ne $field.ExtendedDatatype -or `
                    $applicationField.SQL_Timestamp -ne $field.SQL_Timestamp -or `
                    $applicationField.ClosingDates -ne $field.ClosingDates ) 
                {
                    Write-Verbose -Message "Found field $($applicationField.ID)"
                    $FieldsInSelect += $field.ID
                    $CreateSelectStatement = $true
                }

            } else {
                   Write-Verbose -Message "Found field $($field.ID)"
                   $FieldsInSelect += $field.ID
                   $CreateSelectStatement = $true
            }
        }
    }   

    if ($CreateSelectStatement) {
        foreach ($field in $FieldsInSelect) {
            $fieldName = ($TenantXml.MetaTable.Fields.Field | Where-Object -Property ID -EQ $field).Name
            for ($i = 0;$i -lt $ReplaceChars.Length;$i++) 
            {
                $fieldName = $fieldName.Replace($ReplaceChars[$i],'_')
            }
            if ($SelectFields -ne "") {
                $SelectFields += ","
            }
            $SelectFields += "[${fieldName}] AS Field${field}"
        }
        if ($TenantXml.DocumentElement.Attributes.GetNamedItem("DataPerCompany").Value -eq 1) {
            $TableName = Get-DatabaseTableName -CompanyName $CompanyName -TableName $TenantXml.MetaTable.Name
        } else {
            $TableName = Get-DatabaseTableName -TableName $TenantXml.MetaTable.Name
        }
        
        $SelectStatement = "SELECT ${SelectFields} FROM [${TableName}] FOR XML PATH('Row')"
        Write-Verbose -Message $SelectStatement
        $result = Get-SQLCommandResult -Server $DatabaseServer -Database $TenantDatabase -Command $SelectStatement
        if ($result) {    

            $xmlRowsPropertyName = ($result | Get-Member -MemberType Property).Name
            $sb = [System.Text.StringBuilder]::new()
            $sb.Append("<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"no`"?><TableData><Table></Table><Fields></Fields><Rows>") | Out-Null
            foreach ($line in ($result.$xmlRowsPropertyName).Split("`r")) {
                $sb.Append($line) | Out-Null
            }
            $sb.Append("</Rows></TableData>") | Out-Null
            $TableData = New-Object -TypeName Xml
            $TableData.LoadXml($sb.ToString());

            $node = $TableData.DocumentElement.SelectSingleNode('//Table')
            for ($i = 2;$i -lt $TenantXml.DocumentElement.Attributes.Count;$i++) {
                $attribute = $TableData.CreateAttribute($TenantXml.DocumentElement.Attributes.Item($i).Name)
                $attribute.Value = $TenantXml.DocumentElement.Attributes.Item($i).Value
                $newAttribute = $node.Attributes.Append($attribute)
            }
            $node = $TableData.DocumentElement.SelectSingleNode('//Fields')
            foreach ($field in $FieldsInSelect) {
                $childNode = $TableData.CreateElement('Field')
                $attribute = $TableData.CreateAttribute('ID')
                $attribute.Value = $field
                $newNode = $childNode.Attributes.Append($attribute)
                $attributes = ($TenantXml.MetaTable.Fields.Field | Where-Object -Property ID -EQ $field).Attributes
                for ($i = 1;$i -lt $attributes.Count;$i++) {
                    $attribute = $TableData.CreateAttribute($attributes.Item($i).Name)
                    $attribute.Value = $attributes.Item($i).Value
                    $newNode = $childNode.Attributes.Append($attribute)
                }
                $newNode = $node.AppendChild($childNode)
            }
            $TableData.OuterXml
        }
    } else {
        Write-Verbose -Message "No changed detected for table $($TableId)"
    }
}
