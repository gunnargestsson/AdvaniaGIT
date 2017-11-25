$vsCodeSettingsFolder = Join-Path $SetupParameters.Repository ".vscode"
New-Item -Path $vsCodeSettingsFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
$vsCodeSettingsFile = Join-Path $vsCodeSettingsFolder "settings.json"
if (Test-Path $vsCodeSettingsFile) {
    $vsCodeSettings = Get-Content -Path $vsCodeSettingsFile -Encoding UTF8 | Out-String | ConvertFrom-Json
} else {
    $vsCodeSettings = New-Object -TypeName PSObject
}

if (![bool]($vsCodeSettings.PSObject.Properties.name -match "files.encoding")) {
    $vsCodeSettings | Add-Member -MemberType NoteProperty -Name "files.encoding" -Value ""
}

$vsCodeSettings.'files.encoding' = $SetupParameters.filesEncoding
Set-Content -PassThru $vsCodeSettingsFile -Value (ConvertTo-Json -InputObject $vsCodeSettings) -Encoding UTF8 -Force | Out-Null
