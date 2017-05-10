$allObjects = Get-Item -Path (Join-Path (Join-Path $SetupParameters.Repository $SetupParameters.objectsPath) "*.TXT")
foreach ($object in $allObjects) {
    Write-Verbose "Handling object $object.BasicName"
    $objectData = (Get-Content -Path $object.FullName -Encoding Oem) -split "`r`n"
    $lineNo = 0
    $beginLineNo = 0
    $endLineNo = 0
    foreach ($objectLine in $objectData) {
        $lineNo ++
        if ($objectLine -eq "    BEGIN") {
            $beginLineNo = $lineNo
        }
        if ($objectLine -eq "    END.") {
            $endLineNo = $lineNo
        }        
    }    
    $lineNo = 0
    $objectOutputData = ""
    if ($endLineNo - $beginLineNo -gt 1) {
        Write-Host "Removing comments from $($object.BaseName)..."
        foreach ($objectLine in $objectData) {
            $lineNo ++
            if ($lineNo -gt $beginLineNo -and $lineNo -lt $endLineNo) {            
            } else {
                if ($objectOutputData -gt "") {
                    $objectOutputData += "`r`n"
                }
                $objectOutputData += $objectLine
            }
        }
        Set-Content -Path $object.FullName -Value $objectOutputData -Encoding Oem
    }
}
