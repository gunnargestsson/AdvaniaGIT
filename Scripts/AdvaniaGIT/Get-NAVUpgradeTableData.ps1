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
        [string]$CompanyName,
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        [string]$CustomDatabase
    )

    $CreateSelectStatement = $false

    [xml]$TenantXml = Get-NAVTableMetaDataXml -DatabaseName $TenantDatabase -DatabaseServer $DatabaseServer -TableId $TableId
    [xml]$ApplicationXml = Get-NAVTableMetaDataXml -DatabaseName $ApplicationDatabase -DatabaseServer $DatabaseServer -TableId $TableId

    $ReplaceChars = '."\/%]['''
    $FieldsInSelect = @()
    $SelectFields = "" 
    if ($TenantXml.MetaTable.Keys.FirstChild.Key) {
        $KeyList = $TenantXml.MetaTable.Keys.FirstChild.Key
    } else {
        $KeyList = $TenantXml.MetaTable.Keys.FirstChild.name
    }
    foreach ($field in ($KeyList).split(',')) {
        $FieldsInSelect += $field.substring(5)
    }

    if ($TenantXml.MetaTable.Fields.Field) {
        $FieldList = $TenantXml.MetaTable.Fields.Field
    } else {
        $FieldList = $TenantXml.MetaTable.Fields.MetaField
    }

    if ($ApplicationXml.MetaTable.Fields.Field) {
        $AppFieldList = $ApplicationXml.MetaTable.Fields.Field
    } else {
        $AppFieldList = $ApplicationXml.MetaTable.Fields.MetaField
    }
    
    foreach ($field in $FieldList) {
        if ($FieldsInSelect -contains $field.ID) {
            Write-Verbose -Message "Field $($field.ID) $($field.Name) is a primary key field"
        } elseif ($field.FieldClass -eq "Normal" -or !$field.FieldClass -and $field.Enabled -in ("1","true")) {
            $applicationField = $AppFieldList | Where-Object -Property ID -EQ $field.ID
            if ($applicationField) {     
                if (!(Get-NAVFieldMatch -TenantField $field -ApplicationField $applicationField))
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

    if ($CreateSelectStatement -or $ApplicationXml -eq $null) {
        foreach ($field in $FieldsInSelect) {
            $fieldName = ($FieldList | Where-Object -Property ID -EQ $field).Name
            for ($i = 0;$i -lt $ReplaceChars.Length;$i++) 
            {
                $fieldName = $fieldName.Replace($ReplaceChars[$i],'_')
            }
            if ($SelectFields -ne "") {
                $SelectFields += ","
            }
            $SelectFields += "[${fieldName}] AS Field${field}"
        }
        if ($TenantXml.DocumentElement.Attributes.GetNamedItem("DataPerCompany").Value -eq 1 -or $TenantXml.MetaTable.isDataPerCompany -eq "true") {
            $TableName = Get-DatabaseTableName -CompanyName $CompanyName -TableName $TenantXml.MetaTable.Name
        } else {
            $TableName = Get-DatabaseTableName -TableName $TenantXml.MetaTable.Name
        }
        $CompanyTableName = Get-DatabaseTableName -CompanyName $CompanyName -TableName $TenantXml.MetaTable.Name
        
        if ($CustomDatabase) {
            $result = Get-SQLCommandResult -Server $DatabaseServer -Database $CustomDatabase -Command "SELECT COUNT(*) FROM [${TenantDatabase}].[dbo].[${TableName}]"
            if ([int]$result.Column1 -gt 0) {
                Write-Verbose -Message "Adding table ${TableName}"
                $result = Get-SQLCommandResult -Server $DatabaseServer -Database $CustomDatabase -Command "SELECT ${SelectFields} INTO [${CompanyTableName}] FROM [${TenantDatabase}].[dbo].[${TableName}]"
                $TableData = New-Object -TypeName Xml
                $TableData.LoadXml("<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"no`"?><TableData><Table></Table><Fields></Fields></TableData>");

                $node = $TableData.DocumentElement.SelectSingleNode('//Table')
                for ($i = 1;$i -lt $TenantXml.DocumentElement.Attributes.Count;$i++) {
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
                $XmlAsBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($TableData.OuterXml))
                $result = Get-SQLCommandResult -Server $DatabaseServer -Database $CustomDatabase -Command "INSERT INTO [dbo].[Object] ([Name],[MetaData],[Company]) VALUES ('$($TenantXml.MetaTable.Name)', '${XmlAsBase64}', '$($CompanyName)')"
            }
        } else {
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
                for ($i = 1;$i -lt $TenantXml.DocumentElement.Attributes.Count;$i++) {
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
        }
    } else {
        Write-Verbose -Message "No changed detected for table $($TableId)"
    }
}
