Function Read-MenuSuite {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true,Position = 0)]
        $ObjectFilePath
    )
    $menuItems = @()
    $menuItem = $null
    $menuSuite = Get-Content -Encoding Oem -Path $ObjectFilePath
    foreach ($menuSuiteLine in $menuSuite) {
        $menuSuiteLine = $menuSuiteLine.TrimStart(' ')
        if ($menuSuiteLine.Length -gt 0 -and $menuSuiteLine.Substring(0,1) -eq '{') {
            if ($menuItem) {
                $menuItems += $menuItem
            }
            $menuItem = $null
        }

        $menuItemPos = $menuSuiteLine.IndexOf('MenuItem')
        if ($menuItemPos -gt 0) {   
            $menuItem = New-Object -TypeName PSObject
            $menuItem | Add-Member -MemberType NoteProperty -Name Id -Value $menuSuiteLine.Substring(21,36)
        }

        if ($menuItem) {      
          if ($menuSuiteLine.IndexOf('AccessByPermission') -gt -1) {
            $menuItem | Add-Member -MemberType NoteProperty -Name AccessByPermission -Value $menuSuiteLine.Substring(19).TrimEnd(' }').TrimEnd(';')   
          }
          if ($menuSuiteLine.IndexOf('ApplicationArea') -gt -1) {
            $menuItem | Add-Member -MemberType NoteProperty -Name ApplicationArea -Value $menuSuiteLine.Substring(16).Replace('#','').TrimEnd(' }').TrimEnd(';') 
          }
          if ($menuSuiteLine.IndexOf('DepartmentCategory') -gt -1) {
            $menuItem | Add-Member -MemberType NoteProperty -Name DepartmentCategory -Value $menuSuiteLine.Substring(19).TrimEnd(' }').TrimEnd(';') 
          }
          if ($menuSuiteLine.IndexOf('RunObjectType') -gt -1) {
            $menuItem | Add-Member -MemberType NoteProperty -Name RunObjectType -Value $menuSuiteLine.Substring(14).TrimEnd(' }').TrimEnd(';') 
          }
          if ($menuSuiteLine.IndexOf('RunObjectID') -gt -1) {
            $menuItem | Add-Member -MemberType NoteProperty -Name RunObjectID -Value $menuSuiteLine.Substring(12).TrimEnd(' }').TrimEnd(';') 
          }    
      
          }     
    }

    if ($menuItem) {
        $menuItems += $menuItem
    }
    return $menuItems
}

  