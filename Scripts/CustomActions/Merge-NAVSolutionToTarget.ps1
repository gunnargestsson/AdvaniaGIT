if ($BranchSettings.dockerContainerId -gt "") {
  $SetupParameters.navIdePath = Copy-DockerNAVClient -SetupParameters $SetupParameters -BranchSettings $BranchSettings
}

if ($SetupParameters.BuildMode) {
    $SetupParameters.workFolder = Join-Path $SetupParameters.rootPath "Log\$($SetupParameters.BranchId)"
}

$MergeFolder = (Join-Path $SetupParameters.workFolder 'Merge')
$SourceFolder = (Join-Path $MergeFolder 'Base')
$TargetFolder = (Join-Path $MergeFolder 'TargetObjects')
$ConflictFolder = (Join-Path $MergeFolder 'ConflictObjects')

Remove-Item -Path $TargetFolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item $TargetFolder -ItemType Directory | Out-Null

Remove-Item -Path $ConflictFolder -Recurse -Force -ErrorAction SilentlyContinue
New-Item $ConflictFolder -ItemType Directory | Out-Null

Write-Host Building Target for $($SetupParameters.projectName) on  $($env:COMPUTERNAME) ...
Load-ModelTools -setupParameters $SetupParameters
$Deltas = Get-ChildItem -Path (Join-Path $MergeFolder 'Deltas') -Recurse
foreach ($Delta in $Deltas) 
{        
    $BaseName = $Delta.BaseName
    $ObjectName = Join-Path $SourceFolder ($BaseName + '.txt')
    $TargetName = Join-Path $TargetFolder ($BaseName + '.txt')
    $AppName = Split-Path (Split-Path $Delta.FullName -Parent) -Leaf                    
            
    if (Test-Path -Path $ObjectName)
    {
        Write-Verbose "Merging file $AppName $Delta into $ObjectName..."
        $UpdatedObjects = Update-NAVApplicationObject -Target $ObjectName -Delta $Delta.FullName -Result $TargetName -DateTimeProperty FromModified -ModifiedProperty FromModified -VersionListProperty FromModified -DocumentationConflict ModifiedFirst -Force
        foreach ($obj in $UpdatedObjects) 
        { 
            $UpdateResult = $obj.UpdateResult
        }
        if ($UpdateResult -eq 'Conflict')
        {                        
            Copy-Item -Path $Delta.FullName -Destination (Join-Path $ConflictFolder ($AppName + '_' + $Delta.Name)) -Force
            $UpdatedObjects.Summary | Out-File -FilePath (Join-Path $ConflictFolder ($AppName + '_' + $Delta.BaseName + '.CONFLICT'))
            Copy-Item -Path $ObjectName -Destination (Join-Path $ConflictFolder ($AppName + '_Source_' + $Delta.BaseName + '.TXT'))
            Copy-Item -Path $TargetName -Destination (Join-Path $ConflictFolder ($AppName + '_Target_' + $Delta.BaseName + '.TXT')) -ErrorAction SilentlyContinue
            Write-Warning "Object $AppName $Delta result: $UpdateResult"
        }
        else
        {
            Set-NAVApplicationObjectProperty -Target $TargetName -VersionListProperty (Merge-NAVVersionListString -source (Get-NAVApplicationObjectProperty -Source $ObjectName).VersionList -target (Get-NAVApplicationObjectProperty -Source $TargetName).VersionList)
            Copy-Item -Path $TargetName -Destination $ObjectName -Force
        }
    }
    elseif (Test-Path -Path $Delta.FullName -PathType Leaf)
    {
        Write-Verbose "Copying file $AppName $Delta into $ObjectName..."
        Copy-Item -Path $Delta.FullName -Destination $ObjectName -Force
    }
}

Write-Host Saving As Target.txt
Join-NAVApplicationObjectFile -Source (Join-Path $SourceFolder '*.txt') -Destination (Join-Path $($SetupParameters.workFolder) Target.txt) -Force -ErrorAction Stop

if (Test-Path (Join-Path $MergeFolder "Languages\*.txt")) {
    Write-Host Saving Translations
    New-Item -Path $SetupParameters.LanguagePath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path (Join-Path $MergeFolder "Languages\*.txt") -Destination $SetupParameters.LanguagePath -Force 
}

$Artifacts = Join-Path $SetupParameters.Repository "Artifacts"
New-Item -Path $Artifacts -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
Compress-Archive -Path $MergeFolder -DestinationPath (Join-Path $Artifacts "MergeResults.zip") -CompressionLevel Optimal

UnLoad-ModelTools
