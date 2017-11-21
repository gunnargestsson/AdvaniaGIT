Function Get-NAVVersionSelection {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\NAVVersions.Json"
    )

    
    $navVersions = Get-NAVVersions
    if ($navVersions.Count -eq 1) { return $navVersions | Select-Object -First 1 }
    $navVersionNo = 1
    $menuItems = @()
    foreach ($navVersion in $navVersions.Releases) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $navVersionNo
        $menuItem = Combine-Settings $menuItem $navVersion
        $menuItems += $menuItem
        $navVersionNo ++
    }

    do {
        # Start Menu
        Clear-Host
        Add-BlankLines
        $menuItems | Format-Table -Property No, mainVersion, navRelease -AutoSize | Out-Host
        $input = Read-Host "Please select NAV version (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedNavVersion = $menuItems | Where-Object -Property No -EQ $input
                if ($selectednavVersion) { return $selectednavVersion }
            }
        }
    }
    until ($input -ieq '0')
}
