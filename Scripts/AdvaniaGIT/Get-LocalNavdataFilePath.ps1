Function Get-LocalNavdataFilePath {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$NavdataPath
    )
    if (!$NavdataPath) { $NavdataPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "backup" }
    $Navdatas = Get-ChildItem -Path $NavdataPath -Filter "*.navdata"
    if ($Navdatas.Count -eq 1) { return $Navdatas | Select-Object -First 1 }
    $NavdataNo = 1
    $menuItems = @()
    foreach ($Navdata in $Navdatas) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $NavdataNo
        $menuItem = Combine-Settings $menuItem $Navdata
        $menuItems += $menuItem
        $NavdataNo ++
    }

    do {
        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Name, LastWriteTime -AutoSize | Out-Host
        $input = Read-Host "Please select navdata file number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedNavdata = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedNavdata) { return $selectedNavdata }
            }
        }
    }
    until ($input -ieq '0')
}
    