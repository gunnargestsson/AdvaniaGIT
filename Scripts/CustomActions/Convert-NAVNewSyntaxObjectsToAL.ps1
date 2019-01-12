if ($BranchSettings.dockerContainerId -gt "") { $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings }

if (Test-Path $SetupParameters.NewSyntaxObjectsPath) {
    $Txt2AlPath = Join-Path $SetupParameters.navIdePath "Txt2Al.exe"
    $ALObjectsPath = "$($SetupParameters.VSCodePath)$(Split-Path $SetupParameters.ObjectsPath -Leaf)"
    $TempPath = Join-Path $SetupParameters.WorkFolder "Txt2ALConversion"
    if (Test-Path $Txt2AlPath) {
        New-Item -Path $ALObjectsPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $TempPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        
        foreach ($CALFile in (Get-ChildItem -Path $SetupParameters.NewSyntaxObjectsPath -Filter "*.TXT")) {
            Remove-Item -Path (Join-Path $TempPath "*.*") -Recurse -Force
            Copy-Item -Path $CALFile.FullName -Destination $TempPath
            $ObjectNo = ($CALFile.BaseName).substring(3,($CALFile.BaseName).length - 3)
            $ObjectPath = Join-Path $ALObjectsPath $CALFile.BaseName
            if (!(Test-Path $ObjectPath)) {
                Write-Host "Converting $($CALFile.BaseName) to AL..."
                New-Item -Path $ObjectPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                . $Txt2AlPath --source="${TempPath}" --target="${ObjectPath}" --Rename --extensionStartId="${ObjectNo}"
            }
        }
    } else {
        Write-Host -ForegroundColor Red "Txt 2 AL conversion not supported in this version!"
    }
} else {
    Write-Host -ForegroundColor Red "New Syntax Objects folder must exits!"
}    
