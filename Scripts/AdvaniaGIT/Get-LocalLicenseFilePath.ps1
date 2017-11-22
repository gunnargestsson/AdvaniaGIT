Function Get-LocalLicenseFilePath {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$LicenseFilePath
    )
    if (!$LicenseFilePath) { $LicenseFilePath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "license" }
    $LicenseFiles = Get-ChildItem -Path $LicenseFilePath -Filter "*.flf"
    if ($LicenseFiles.Count -eq 1) { return $LicenseFiles | Select-Object -First 1 }
    $LicenseFileNo = 1
    $menuItems = @()
    foreach ($LicenseFile in $LicenseFiles) {
        $menuItem = New-Object -TypeName PSObject
        $menuItem | Add-Member -MemberType NoteProperty -Name No -Value $LicenseFileNo
        $menuItem = Combine-Settings $menuItem $LicenseFile
        $menuItems += $menuItem
        $LicenseFileNo ++
    }

    do {
        # Start Menu
        Clear-Host
        Add-BlankLines
        $menuItems | Format-Table -Property No, Name, LastWriteTime -AutoSize | Out-Host
        $input = Read-Host "Please select License file number (0 = exit)"
        switch ($input) {
            '0' { break }
            default {
                $selectedLicenseFile = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedLicenseFile) { return $selectedLicenseFile }
            }
        }
    }
    until ($input -ieq '0')
}
    