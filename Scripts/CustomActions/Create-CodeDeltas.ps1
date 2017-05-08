Load-ModelTools -SetupParameters $SetupParameters
$SourceFileName = (Join-Path $WorkFolder 'Source.txt')
$SourceFolderName = (Join-Path $WorkFolder 'Srcs')
$ModifiedFileName = (Join-Path $WorkFolder 'Modified.txt')
$ModifiedFolderName = (Join-Path $WorkFolder 'Mods')
$DeltaFolder = (Join-Path $WorkFolder 'Deltas')

if (Test-Path $DeltaFolder)
{
  Remove-Item -Path $DeltaFolder -Recurse -Force
}
New-Item -Path $DeltaFolder -ItemType Directory | Out-Null
if (Test-Path $ModifiedFolderName)
{
  Remove-Item -Path $ModifiedFolderName -Recurse -Force
}
New-Item -Path $ModifiedFolderName -ItemType Directory | Out-Null
if (Test-Path $SourceFolderName)
{
  Remove-Item -Path $SourceFolderName -Recurse -Force
}
New-Item -Path $SourceFolderName -ItemType Directory | Out-Null

Write-Host "Preparing objects for compare..."
Split-NAVApplicationObjectFile -Source $SourceFileName -Destination $SourceFolderName -Force
Split-NAVApplicationObjectFile -Source $ModifiedFileName -Destination $ModifiedFolderName -Force
foreach ($sourceObject in (Get-ChildItem -Path $SourceFolderName)) {
  $modifiedObject = (Join-Path $ModifiedFolderName $sourceObject.Name)
  if (Test-Path $modifiedObject) {
      $SourceObjectProperties = Get-NAVApplicationObjectProperty -Source $sourceObject.FullName
      if ($SourceObjectProperties.Modified -eq $false) {
          Set-NAVApplicationObjectProperty -TargetPath $modifiedObject `
            -VersionListProperty $SourceObjectProperties.VersionList `
            -ModifiedProperty No `
            -DateTimeProperty ($SourceObjectProperties.Date + " " + $SourceObjectProperties.Time) 
      } else {    
          Set-NAVApplicationObjectProperty -TargetPath $modifiedObject `
            -VersionListProperty $SourceObjectProperties.VersionList `
            -ModifiedProperty Yes `
            -DateTimeProperty ($SourceObjectProperties.Date + " " + $SourceObjectProperties.Time) 
      }
  }
}


Write-Host "Comparing Source.txt and Modified.txt..."
Compare-NAVApplicationObject -Original $SourceFolderName -Modified $ModifiedFolderName -Delta $DeltaFolder | Where-Object CompareResult -eq 'Identical' | foreach {  Remove-Item (Join-Path $DeltaFolder ($_.ObjectType.substring(0,3) + $_.Id + '.delta')) }
