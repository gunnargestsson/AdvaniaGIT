Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module -Name AdvaniaGIT -DisableNameChecking

$SetupParameters = Get-GITSettings
$Licenses = Get-ChildItem -Path "V:\Allir_Advania\VL\Umsjónartól - leyfi" -Recurse -Filter "*.flf"
$i = 0
$count = $Licenses.Count
$StartTime = Get-Date
foreach ($License in $Licenses | Sort-Object -Property LastWriteTime) {
    $i++
    $NowTime = Get-Date
    $TimeSpan = New-TimeSpan $StartTime $NowTime
    $percent = $i / $count
    if ($percent -gt 1) 
    {
        $percent = 1
    }
    $remtime = $TimeSpan.TotalSeconds / $percent * (1-$percent)
    if (($i % 10) -eq 0) 
    {
        Write-Progress -Status "Processing $i of $count" -Activity 'Copying license...' -PercentComplete ($percent*100) -SecondsRemaining $remtime
    }
    $LicenseName = $License.BaseName.SubString(0,7)
    if ($LicenseName -match "^[\d\.]+$") {
        $FtpFileName = "License/${LicenseName}.flf"
        Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath $FtpFileName -LocalFilePath $License.FullName
    }        
}
