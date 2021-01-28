Function Get-NAVFieldMatch{
    Param($TenantField,$ApplicationField)
    
    if ($ApplicationField.Datatype -eq $TenantField.Datatype -and `
        $ApplicationField.DataLength -ge $TenantField.DataLength -and `
        $ApplicationField.Enabled -eq $TenantField.Enabled -and `
        $ApplicationField.FieldClass -eq $TenantField.FieldClass) { return $true }
                
        
    if ([bool]($ApplicationField.PSObject.Properties.name -EQ "Datatype") -and [bool]($TenantField.PSObject.Properties.name -EQ "Datatype" -and $ApplicationField.Datatype -ne $TenantField.Datatype )) { return $false }
    if ([bool]($ApplicationField.PSObject.Properties.name -EQ "Datatype") -and [bool]($TenantField.PSObject.Properties.name -EQ "Type" -and $ApplicationField.Datatype -ne $TenantField.Type )) { return $false }
    if ([bool]($ApplicationField.PSObject.Properties.name -EQ "FieldClass") -and [bool]($TenantField.PSObject.Properties.name -EQ "FieldClass" -and $ApplicationField.FieldClass -ne $TenantField.FieldClass )) { return $false }
    if ($ApplicationField.Enabled -in @("true","1") -and $TenantField.Enabled -in @("false","0") ) { return $false }
    if ([bool]($ApplicationField.PSObject.Properties.name -EQ "DataLength") -and [bool]($TenantField.PSObject.Properties.name -EQ "DataLength" -and $ApplicationField.DataLength -ne $TenantField.DataLength )) { return $false }
    if ([bool]($ApplicationField.PSObject.Properties.name -EQ "DataLength") -and [bool]($TenantField.PSObject.Properties.name -EQ "Length" -and $ApplicationField.DataLength -lt $TenantField.Length )) { return $false }

    return $true

}