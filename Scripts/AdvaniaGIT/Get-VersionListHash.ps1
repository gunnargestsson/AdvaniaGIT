function Get-VersionListHash
{
    param
    (
        [System.String]
        $versionlist
    )

    $hash = @{}
    $versionlistarray = $versionlist.Split(',')
    foreach ($element in $versionlistarray) 
    {
        $moduleinfo = Get-VersionListModuleShortcut($element)
        if (!$hash.ContainsKey($moduleinfo.shortcut)) {$hash.Add($moduleinfo.shortcut,$moduleinfo.version) }
    }
    return $hash
}