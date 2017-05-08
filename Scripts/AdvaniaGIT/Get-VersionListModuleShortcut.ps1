function Get-VersionListModuleShortcut
{
    param
    (
        [System.String]
        $part
    )

    $index = $part.IndexOfAny('0123456789')
    if ($index -ge 1) 
    {
        $result = @{
            'shortcut' = $part.Substring(0,$index)
            'version' = $part.Substring($index)
        }
    }
    else 
    {
        $result = @{
            'shortcut' = $part
            'version' = ''
        }
    }
    return $result
}
