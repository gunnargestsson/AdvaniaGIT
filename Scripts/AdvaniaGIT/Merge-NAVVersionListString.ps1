function Merge-NAVVersionListString
{
    param
    (
        [String]$source,
        [String]$target,
        [String]$newversion,
        [Switch]$SourceFirst
    )

    if (!$SourceFirst) 
    {
        $temp = $source
        $source = $target
        $target = $temp
    }
    $result = ''
    $sourcearray = $source.Split(',')
    $targetarray = $target.Split(',')
    $sourcehash = Get-VersionListHash($source)
    $targethash = Get-VersionListHash($target)
    $newmoduleinfo = Get-VersionListModuleShortcut($newversion)
    foreach ($module in $sourcearray) 
    {
        $actualversion = ''
        $moduleinfo = Get-VersionListModuleShortcut($module)
        $actualversion = Get-NAVHighestVersionList -Prefix $moduleinfo.shortcut -VersionList1 $sourcehash[$moduleinfo.shortcut] -VersionList2 $targethash[$moduleinfo.shortcut]
        if ($result.Length -gt 0) 
        {
            $result = $result + ','
        }
        $result = $result + $moduleinfo.shortcut + $actualversion
    }
    foreach ($module in $targetarray) 
    {
        $moduleinfo = Get-VersionListModuleShortcut($module)
        if (!$sourcehash.ContainsKey($moduleinfo.shortcut)) 
        {
            if ($result.Length -gt 0) 
            {
                $result = $result + ','
            }
            if ($moduleinfo.shortcut -eq $newmoduleinfo.shortcut) 
            {
                $result = $result + $newversion
            }
            else 
            {
                $result = $result + $module
            }
        }
    }
    if ($result -notlike "*$($newmoduleinfo.shortcut)*") {
        $result = $result + ',' + $newversion
    }
    $result = $result.TrimStart(',')
    return $result
}
