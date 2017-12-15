if ($BranchSettings.dockerContainerId -gt "") {
    Start-DockerCustomAction -BranchSettings $BranchSettings -ScriptName $MyInvocation.MyCommand.Name -BuildSettings $BuildSettings
} else {    
    Load-ModelTools -SetupParameters $SetupParameters

    $SourceFileName = (Join-Path $SetupParameters.workFolder 'Source.txt')
    $TargetFileName = (Join-Path $SetupParameters.workFolder 'Target.txt')
    $DeltaFolder = (Join-Path $SetupParameters.workFolder 'Deltas')

    $newFolder = (Join-Path $SetupParameters.workFolder 'SourceObjects')
    $newCustomizedFolder = (Join-Path $SetupParameters.workFolder 'TargetObjects')

    Remove-Item -Path $newFolder -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $newCustomizedFolder -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $newFolder -ItemType Directory | Out-Null
    New-Item -Path $newCustomizedFolder -ItemType Directory | Out-Null

    Write-Host "Splitting Source.txt objects..."
    Split-NAVApplicationObjectFile $SourceFileName $newFolder
    Write-Host "Removing unchanged new objects..."
    Get-ChildItem -Path $newFolder | foreach { if (!(Test-Path ((Join-Path $DeltaFolder $_.BaseName) + '.delta'))) { Remove-Item $_.FullName } }
    Write-Host "Updating new objects..."
    Update-NAVApplicationObject -Target $newFolder -Delta $DeltaFolder -Result $newCustomizedFolder -DateTimeProperty FromModified -ModifiedProperty FromModified -VersionListProperty FromModified -DocumentationConflict ModifiedFirst
    Write-Host "Updating customized object version list..."
    Get-ChildItem -Path (Join-Path $newCustomizedFolder '*.txt')| foreach { if (Test-Path (Join-Path $newFolder $_.Name)) {Set-NAVApplicationObjectProperty -Target $_.FullName -VersionListProperty (Merge-NAVVersionListString -source (Get-NAVApplicationObjectProperty -Source $_.FullName).VersionList -target (Get-NAVApplicationObjectProperty -Source (Join-Path $newFolder $_.Name)).VersionList) }}
    Write-Host "Joining customized object to a single file..."
    Join-NAVApplicationObjectFile -Source (Join-Path $newCustomizedFolder '*.txt') -Destination $TargetFileName -Force
    Write-Host "If you have conflicts then you need to manually fix conflicting code changes"
    Get-Item -Path (Join-Path $newCustomizedFolder '*.conflict') 
}