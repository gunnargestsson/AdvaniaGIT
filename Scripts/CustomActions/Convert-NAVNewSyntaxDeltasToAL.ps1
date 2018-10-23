if ($BranchSettings.dockerContainerId -gt "") { $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings }

if (Test-Path $SetupParameters.NewSyntaxDeltasPath) {
    $Txt2AlPath = Join-Path $SetupParameters.navIdePath "Txt2Al.exe"
    $TempPath = Join-Path $SetupParameters.WorkFolder "Txt2ALConversion"
    if (Test-Path $Txt2AlPath) {
        New-Item -Path $SetupParameters.VSCodePath -ItemType Directory -ErrorAction SilentlyContinue
        New-Item -Path $TempPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $SetupParameters.VSCodePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path (Join-Path $SetupParameters.VSCodePath "Source") -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        foreach ($CALFile in (Get-ChildItem -Path $SetupParameters.NewSyntaxDeltasPath -Filter "*.DELTA")) {
            Remove-Item -Path (Join-Path $TempPath "*.*") -Recurse -Force
            Copy-Item -Path $CALFile.FullName -Destination $TempPath
            $ObjectNo = ($CALFile.BaseName).substring(3,($CALFile.BaseName).length - 3)
            $ObjectType = $CALFile.BaseName.substring(0,3)
            $ObjectPath = Join-Path (Join-Path (Join-Path $SetupParameters.VSCodePath "Source") $ObjectType) $ObjectNo
            Write-Host "Converting $($CALFile.BaseName) to AL..."
            New-Item -Path (Split-Path -Path $ObjectPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            New-Item -Path $ObjectPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            . $Txt2AlPath --source="${TempPath}" --target="${ObjectPath}" --Rename --extensionStartId="${ObjectNo}"
        }
    } else {
        Write-Host -ForegroundColor Red "Txt 2 AL conversion not supported in this version!"
    }
} else {
    Write-Host -ForegroundColor Red "New Syntax Delta folder must exits!"
}    
