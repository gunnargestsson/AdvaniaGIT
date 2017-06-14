function ConvertTo-Settings
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [Hashtable]$Object1
    )

    $Object2 = New-Object -TypeName PSObject
    $Keys = $Object1.Keys
    
    foreach ($Key in $Keys) {
        Write-Verbose ('Adding property: {0}' -f $Key);
        $KeyValue = $Object1.Item($Key)
        if ($KeyValue.SubString(0,1) -eq "$") {
            Add-Member -InputObject $Object2 -Name $Key -MemberType NoteProperty -Value $(Invoke-Expression $KeyValue)
        } else {
            Add-Member -InputObject $Object2 -Name $Key -MemberType NoteProperty -Value $KeyValue;
        }
    }
    $Object2 | select *;
}