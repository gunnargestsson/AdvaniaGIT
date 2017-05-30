function Get-DatabaseTableName
{
    param(
        $CompanyName,
        $TableName
    )    
    $ReplaceChars = '."\/%]['''  ## ToDo - Get from Database ndo$dbproperty

    $DBTableName = $CompanyName + "$" + $TableName
    for ($i = 0;$i -lt $ReplaceChars.Length;$i++) 
    {
        $DBTableName = $DBTableName.Replace($ReplaceChars[$i],'_')
    }
    return $DBTableName
}