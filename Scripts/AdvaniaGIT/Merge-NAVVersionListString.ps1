Add-Type -Language CSharp -TypeDefinition @"
  public enum VersionListMergeMode
  {
    SourceFirst,
    TargetFirst
  }
"@ -ErrorAction SilentlyContinue

function Merge-NAVVersionListString 
{
    param
    (
        [System.String]
        $source,

        [System.String]
        $target,

        [System.String]
        $newversion,

        [String]
        $mode = [VersionListMergeMode]::SourceFirst
    )

    if ($mode -eq [VersionListMergeMode]::TargetFirst) 
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
        $actualversion = Get-NAVVersionListBigger $sourcehash[$moduleinfo.shortcut] $targethash[$moduleinfo.shortcut]

        if ($moduleinfo.shortcut -eq $newmoduleinfo.shortcut) 
        {
            $actualversion = $newmoduleinfo.version
        }
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
