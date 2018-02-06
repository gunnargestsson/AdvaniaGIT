$AppManifestPath = (Join-Path $SetupParameters.Repository 'AL\app.json')
if (!(Test-Path $AppManifestPath)) {
    Write-Host -ForegroundColor Red "AL project not found in repository!"
    throw
}

Write-Host "Updating manifest features..."
$AppManifest = Get-Content -Path $AppManifestPath -Encoding UTF8 | Out-String | ConvertFrom-Json
if (![bool]($AppManifest.PSObject.Properties.name -match "features")) {
        $AppManifest | Add-Member -MemberType NoteProperty -Name features -Value @()
        
}
if (!($AppManifest.features.Contains("TranslationFile"))) {
    $AppManifest.features += "TranslationFile"
    Set-Content -PassThru $AppManifestPath -Encoding UTF8 -Value ($AppManifest | ConvertTo-Json)
}
    

Write-Host "Updating AL files..."
$ALFiles = Get-ChildItem -Path (Join-Path $SetupParameters.Repository 'AL') -Filter *.al -Recurse
foreach ($ALFile in $ALFiles) {
    Write-Verbose "Handling object $ALFile.BasicName"
    $ALFileData = (Get-Content -Path $ALFile.FullName -Encoding UTF8) -split "`r`n"   
    $ALFileOutputData = "" 
    $inQuotes = $false
    foreach ($ALFileLine in $ALFileData) {
        if ($ALFileLine -match "TextConst") {
            $pos = $ALFileLine.IndexOf(':')
            $line =  $ALFileLine.Substring($pos + 12).TrimEnd(';')
            $myHash = Convert-NAVMLStringToHash $line
            $ALFileOutputData += $ALFileLine.Substring(0,$pos + 2) + "Label " + $myHash.Item('ENU')
            if ($myHash.ContainsKey('Comment')) {
                if ($myHash.Item('Comment') -match "{Locked}") {
                    $ALFileOutputData += ",Locked=true;"
                } else {
                    $ALFileOutputData += ",Comment=$($myHash.Item('Comment'));"
                }
            } else {
                $ALFileOutputData += ";"
            }
        } elseif ($ALFileLine -match "CaptionML=" -or $ALFileLine -match "ToolTipML=" -or $ALFileLine -match "InstructionalTextML=" -or $ALFileLine -match "OptionCaptionML=") {
            $pos = $ALFileLine.IndexOf('=')
            $line =  $ALFileLine.Substring($pos + 1).TrimEnd(';')
            $myHash = Convert-NAVMLStringToHash $line
            $ALFileOutputData += $ALFileLine.Substring(0,$pos - 2) + "=" + $myHash.Item('ENU') + ';'
        } else {
            $ALFileOutputData += $ALFileLine        
        }
        $ALFileOutputData += "`r`n"
        
    }    
    Set-Content -Path $ALFile.FullName -Value $ALFileOutputData -Encoding UTF8
}
    