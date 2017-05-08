Load-ModelTools -SetupParameters $SetupParameters
$SourceFileName = (Join-Path $WorkFolder 'Source.txt') 
$ModifiedFileName = (Join-Path $WorkFolder 'Modified.txt')
$DeltaFolder = (Join-Path $WorkFolder 'Deltas')

if (Test-Path $DeltaFolder)
{
  Remove-Item -Path $DeltaFolder -Recurse -Force
}
New-Item -Path $DeltaFolder -ItemType Directory | Out-Null


Write-Host "Comparing Source.txt and Modified.txt..."
Compare-NAVApplicationObject -Original $SourceFileName -Modified $ModifiedFileName -Delta $DeltaFolder | Where-Object CompareResult -eq 'Identical' | foreach {  Remove-Item (Join-Path $DeltaFolder ($_.ObjectType.substring(0,3) + $_.Id + '.delta')) }
