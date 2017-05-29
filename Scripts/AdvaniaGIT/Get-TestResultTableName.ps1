function Get-TestResultTableName
{
    param(
        $CompanyName
    )
    $ResultTableName = 'CAL Test Result'
    $ReplaceChars = '."\/%]['''  ## ToDo - Get from Database ndo$dbproperty

    $DBCompanyName = $CompanyName
    for ($i = 0;$i -lt $ReplaceChars.Length;$i++) 
    {
        $DBCompanyName = $DBCompanyName.Replace($ReplaceChars[$i],'_')
    }
    return $DBCompanyName + "$" + $ResultTableName
}