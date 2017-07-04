Function Get-LocalBacPacFilePath {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$BacpacPath
    )
    if (!$BacpacPath) { $BacpacPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "backup" }
    $bacpacs = Get-ChildItem -Path $BacpacPath -Filter "*.bacpac"
    if ($bacpacs.Count -eq 1) { return $bacpacs | Select-Object -First 1 }
    $bacpacNo = 1
    $menuItems = @()
    foreach ($bacpac in $bacpacs) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $bacpacNo
        $menuItem = Combine-Settings $menuItem $bacpac
        $menuItems += $menuItem
        $bacpacNo ++
    }

    do {
        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems | Format-Table -Property No, Name, Lenght, LastWriteTime -AutoSize | Out-Host
        $input = Read-Host "Please select bacpac file number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedBacpac = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedBacpac) { return $selectedBacpac }
            }
        }
    }
    until ($input -ieq '0')
}
    