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
    $inObject = $true
    for ($c = 0; $c -lt $ALFileData.Length; $c++) {
        $ALFileLine = $ALFileData.Item($c)        
        if ($inObject) {
            $CompactedAlFileLine = $ALFileLine.replace(' ','')
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
            } elseif ($CompactedAlFileLine -match "CaptionML=" -or $CompactedAlFileLine -match "ToolTipML=" -or $CompactedAlFileLine -match "InstructionalTextML=" -or $CompactedAlFileLine -match "OptionCaptionML=" -or $CompactedAlFileLine -match "PromotedActionCategoriesML=") {
                $ALFileLine = $ALFileLine.replace("CaptionML","Caption")
                $ALFileLine = $ALFileLine.replace("ToolTipML","ToolTip")
                $ALFileLine = $ALFileLine.replace("InstructionalTextML","InstructionalText")
                $ALFileLine = $ALFileLine.replace("OptionCaptionML","OptionCaption")
                $ALFileLine = $ALFileLine.replace("PromotedActionCategoriesML","PromotedActionCategories")
                $pos = $ALFileLine.IndexOf('=')
                $line =  $ALFileLine.Substring($pos + 1).TrimStart(' ')
                while ($line -eq $line.TrimEnd(';')) {
                    $c ++
                    $line += $ALFileData.Item($c).TrimStart(' ')
                } 
                $myHash = Convert-NAVMLStringToHash $line.TrimEnd(';')
                $ALFileOutputData += $ALFileLine.Substring(0,$pos - 1) + " = " + $myHash.Item('ENU') + ';'
            } else {
                $ALFileOutputData += $ALFileLine        
            }
            $ALFileOutputData += "`r`n"
        }
        if ($ALFileLine -eq '}') { $inObject = $false }
        
    }    
    Set-Content -Path $ALFile.FullName -Value $ALFileOutputData -Encoding UTF8
}
    