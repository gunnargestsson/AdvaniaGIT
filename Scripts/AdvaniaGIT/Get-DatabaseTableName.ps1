function Get-DatabaseTableName
{
    param(
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName = $true)]
        $CompanyName,
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        $TableName
    )    
    $ReplaceChars = '."\/%]['''  ## ToDo - Get from Database ndo$dbproperty

    if ([String]::IsNullOrEmpty($CompanyName)) {
        $DBTableName = $TableName
    } else {
        $DBTableName = $CompanyName + "$" + $TableName        
    }

    for ($i = 0;$i -lt $ReplaceChars.Length;$i++) 
    {
        $DBTableName = $DBTableName.Replace($ReplaceChars[$i],'_')
    }
    return $DBTableName
}