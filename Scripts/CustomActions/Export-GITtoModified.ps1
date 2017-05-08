Load-ModelTools -SetupParameters $SetupParameters
$ObjectFileName = (Join-Path $workFolder 'Modified.txt')
if (Test-Path $ObjectFileName)
{
    Remove-Item -Path $ObjectFileName  -Force
}
$ObjectsPath = Build-Solution -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath $ObjectsPath
Join-NAVApplicationObjectFile -Source (Join-Path $ObjectsPath '*.txt') -Destination $ObjectFileName -Force
UnLoad-ModelTools
