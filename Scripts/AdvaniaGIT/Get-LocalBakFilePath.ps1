Function Get-LocalBakFilePath {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$BakPath
    )
    if (!$BakPath) { $BakPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "backup" }
    $Baks = Get-ChildItem -Path $BakPath -Filter "*.bak"
    if ($Baks.Count -eq 1) { return $Baks | Select-Object -First 1 }
    $BakNo = 1
    $menuItems = @()
    foreach ($Bak in $Baks) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $BakNo
        $menuItem = Combine-Settings $menuItem $Bak
        $menuItems += $menuItem
        $BakNo ++
    }

    do {
        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Name, LastWriteTime -AutoSize | Out-Host
        $input = Read-Host "Please select bak file number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedBak = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedBak) { return $selectedBak }
            }
        }
    }
    until ($input -ieq '0')
}
    