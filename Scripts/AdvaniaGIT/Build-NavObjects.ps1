function Build-NAVObjects
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$Repository,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$BranchSettings,    
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$TargetFileName,
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
    [String]$IncludeCustomization
    )

    Load-ModelTools -setupParameters $SetupParameters

    $MergeFolder = (Join-Path $($SetupParameters.workFolder) 'Merge')
    Remove-Item -Path $MergeFolder -Recurse -Force -ErrorAction SilentlyContinue
    New-Item $MergeFolder -ItemType Directory | Out-Null
    New-Item (Join-Path $MergeFolder 'Base') -ItemType Directory | Out-Null
    New-Item (Join-Path $MergeFolder 'Deltas') -ItemType Directory | Out-Null

    $sourcebranch = git.exe rev-parse --abbrev-ref HEAD 
    Write-Host Save Source Branch $sourcebranch

    Write-Host Get objects from $SetupParameters.baseBranch
    $result = git.exe checkout --force $SetupParameters.baseBranch --quiet 
    $BaseSetupParameters = Get-Content (Join-Path $Repository $($SetupParameters.setupPath)) | Out-String | ConvertFrom-Json
    if ($BaseSetupParameters.storeAllObjects -eq "false" -or $BaseSetupParameters.storeAllObjects -eq $false) {
        Split-NAVApplicationObjectFile -Source (Get-BaseObjectsPath -SetupParameters $BaseSetupParameters) -Destination (Join-Path $MergeFolder 'Base') -Force
    } else {
        Copy-Item -Path (Join-Path (Join-Path $Repository $($SetupParameters.objectsPath)) '*.txt') -Destination (Join-Path $MergeFolder 'Base') -Force
    }
    $DeltaFolderIndexNo = 10000
    if ($SetupParameters.deltaBranchList) {
        $deltaBranchList = ($SetupParameters.deltaBranchList).split(",")
        foreach ($deltaBranch in $deltaBranchList)
        {
          Start-Sleep -Seconds 1
          Write-Host Get deltas from $deltaBranch
          $result = git.exe checkout --force $deltaBranch --quiet 
          $branchFolder = (Join-Path (Join-Path $MergeFolder 'Deltas') ($DeltaFolderIndexNo.ToString() + $deltaBranch))
          New-Item $branchFolder -ItemType Directory | Out-Null
          Copy-Item -Path (Join-Path (Join-Path $Repository $($SetupParameters.deltasPath)) '*.delta') -Destination $branchFolder -Force 
          $DeltaFolderIndexNo += 10
        }
    }

    Write-Host Switching back to Source Branch
    $result = git.exe checkout --force $sourcebranch --quiet 

    if ($IncludeCustomization -eq $true)
    {
        if (Test-Path (Join-Path $Repository $($SetupParameters.deltasPath))) 
        {
          Write-Host Get deltas from $sourcebranch  
          $branchFolder = (Join-Path $MergeFolder $sourcebranch)
          New-Item $branchFolder -ItemType Directory | Out-Null
          Copy-Item -Path (Join-Path (Join-Path $Repository $($SetupParameters.deltasPath)) '*.delta') -Destination $branchFolder -Force -Recurse
        }
    }

    $SourceFolder = (Join-Path $MergeFolder 'Base')
    $TargetFolder = (Join-Path $MergeFolder 'TargetObjects')
    $ConflictFolder = (Join-Path $MergeFolder 'ConflictObjects')

    Remove-Item -Path $TargetFolder -Recurse -Force -ErrorAction SilentlyContinue
    New-Item $TargetFolder -ItemType Directory | Out-Null

    Remove-Item -Path $ConflictFolder -Recurse -Force -ErrorAction SilentlyContinue
    New-Item $ConflictFolder -ItemType Directory | Out-Null

    Write-Host Building Target...
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

    if ($IncludeCustomization -eq $true) 
    {
        Write-Host Adding customizations...
        if (Test-Path (Join-Path $MergeFolder $sourcebranch)) 
        {
            $Deltas = Get-ChildItem -Path (Join-Path $MergeFolder $sourcebranch) -Recurse
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
        }
    }

    Write-Host Saving As $TargetFileName
    Join-NAVApplicationObjectFile -Source (Join-Path $SourceFolder '*.txt') -Destination (Join-Path $($SetupParameters.workFolder) $TargetFileName) -Force
}