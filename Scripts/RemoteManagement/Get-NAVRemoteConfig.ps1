Function Get-NAVRemoteConfig {
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SettingsFilePath = "Data\RemoteSettings*.Json",
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$Initial
    )

    if ($Initial -or [String]::IsNullOrEmpty($Global:SettingsFilePath)) {
        $Configs = Get-ChildItem -Path (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) $SettingsFilePath)
        if ($Configs.count -eq 1) {
            $ConfigPath = $Configs[0].FullName
        } else {
            $index = 1
            foreach ($ConfigPath in $Configs) {
                $ConfigPath | Add-Member -MemberType NoteProperty -Name No -Value $index
                $index += 1
            }

            # Start Menu
            Clear-Host
            For ($i=0; $i -le 10; $i++) { Write-Host "" }
            $Configs | Format-Table -Property No, BaseName -AutoSize | Out-Host
            $input = Read-Host "Please select Configuration configuration (0 = cancel)"
            switch ($input) {
                '0' { throw }
                default { $ConfigPath = $Configs | Where-Object -Property No -EQ $input }
            }
        }        
    } else {
        $ConfigPath = $Global:SettingsFilePath
    }
    if (Test-Path -Path $ConfigPath) {
        $Global:SettingsFilePath = $ConfigPath
        $Config = Get-Content -Path $ConfigPath | Out-String | ConvertFrom-Json
        return $Config
    } else {
        Write-Host "Remote configuration not found!"
        Throw
    }
}