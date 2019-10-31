function Reverse-HashTable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        $Hashtable
    )

    
    $TempHashTable = @()
    $Reverse = @()
    foreach ($obj in $Hashtable) {
        $key += 1
        $obj | Add-Member -MemberType NoteProperty -Name Key -Value $key
        $TempHashTable += $obj
    }
    foreach ($obj in $TempHashTable | Sort-Object -Property Key -Descending) {
        $obj.PSObject.Properties.Remove('Key')
        $Reverse += $obj
    }
    
    return $Reverse
}