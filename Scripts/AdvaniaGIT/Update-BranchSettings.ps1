function Update-BranchSettings
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "Data\BranchSettings.Json"),
        [Parameter(Mandatory=$False)]
        [Switch]$Clear
    )
    $file = $null
    while (!($file)) {
        try {
            $file = [System.IO.File]::Open($SettingsFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read)
        } catch [System.IO.IOException]  {
            Start-Sleep -Seconds 1
        }
    }
    $content = New-Object System.Byte[] ($file.Length)
    $file.Read($content, 0, $file.Length) | Out-Null    
    $allBranchSettings = [System.Text.Encoding]::UTF8.GetString($content) | Out-String | ConvertFrom-Json
    $newBranchSettings = @()
    $allBranchSettings.Branches | Where-Object -Property branchId -NE $BranchSettings.branchId | foreach {$newBranchSettings += $_}
    if (!$Clear) {$newBranchSettings += $BranchSettings}
    $allBranchSettings.Branches = $newBranchSettings
    $content = [System.Text.Encoding]::UTF8.GetBytes(($allBranchSettings | ConvertTo-Json))
    $file.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
    $file.Write($content, 0, $content.Length)
    $file.SetLength($content.Length)
    $file.Flush()
    $file.Dispose()    
}