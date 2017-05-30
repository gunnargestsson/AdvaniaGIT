function Get-NAVVersionListBigger
{
    param
    (
        [System.String]$list1='',
        [System.String]$list2=''
    )
    $l1 = $list1.IndexOf('.')
    $l2 = $list2.IndexOf('.')
    $l = [math]::Max($l1,$l2)

    $list1b = $list1.PadLeft($list1.Length+$l-$l1,'0')
    $list2b = $list2.PadLeft($list2.Length+$l-$l2,'0')
    if ($list1b -ge $list2b) {
        return $list1
    } else {
        return $list2
    }
}
