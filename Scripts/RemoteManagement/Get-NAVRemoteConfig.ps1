Function Get-NAVRemoteConfig {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\RemoteSettings*.Json",
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$Initial
    )

    if ($Initial) {
        $Configs = Get-ChildItem -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath)
        if ($Configs.count -eq 1) {
            $SettingsFilePath = $Configs[0].FullName
        } else {
            $index = 1
            foreach ($Config in $Configs) {
                $Config | Add-Member -MemberType NoteProperty -Name No -Value $index
                $index += 1
            }


        # Start Menu
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $Configs | Format-Table -Property No, BaseName -AutoSize | Out-Host
        $input = Read-Host "Please select Configuration configuration (0 = cancel)"
        switch ($input) {
            '0' { throw }
            default { $SettingsFilePath = $Configs | Where-Object -Property No -EQ $input }
            }
        }        
    } else {
        $SettingsFilePath = $Global:SettingsFilePath
    }
    if (Test-Path -Path $SettingsFilePath) {
        $Global:SettingsFilePath = $SettingsFilePath
        $Config = Get-Content -Path $SettingsFilePath | Out-String | ConvertFrom-Json
        return $Config
    } else {
        Write-Host "Remote configuration not found!"
        Throw
    }
}