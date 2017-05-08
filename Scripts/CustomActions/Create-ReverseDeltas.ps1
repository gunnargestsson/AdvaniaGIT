Load-ModelTools -SetupParameters $SetupParameters
$SourceFileName = (Join-Path $workFolder 'Source.txt')
$ModifiedFileName = (Join-Path $workFolder 'Modified.txt')
$DeltaFolder = (Join-Path $workFolder 'ReverseDeltas')

if (Test-Path $DeltaFolder)
{
  Remove-Item -Path $DeltaFolder -Recurse -Force
}
New-Item -Path $DeltaFolder -ItemType Directory | Out-Null

Write-Host "Comparing Modified.txt and Source.txt..."
Compare-NAVApplicationObject -Original $ModifiedFileName -Modified $SourceFileName -Delta $DeltaFolder | Where-Object CompareResult -eq 'Identical' | foreach {  Remove-Item (Join-Path $DeltaFolder ($_.ObjectType.substring(0,3) + $_.Id + '.delta')) }
