Function Convert-NAVMLStringToHash 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyname=$true)]
        [String]$Line
    )

    $aggChar = ""
    $myHash=@{}
    for ($c = 1; $c -le $Line.Length; $c++) {
        $char = $Line.Substring($c - 1,1)
        if ($char -eq "'") { $inQuotes = !$inQuotes }
        if ($inQuotes -or $char -eq "'") { 
            $aggChar += $char 
        } elseif (!$inQotes -and $char -eq "=") {
            $property = $aggChar
            $aggChar = ""
        } elseif (!$inQuotes -and $char -eq ",") {
            $myHash.Add($property,$aggChar)
            $aggChar = ""
        } else {
            $aggChar += $char
        }                
    }            
    $myHash.Add($property,$aggChar)
    return $myHash
}