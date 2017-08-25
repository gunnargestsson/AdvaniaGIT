function Convert-NAVObjectsDateTime
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$FromCulture,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$ToCulture,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [String]$ObjectPath
    )

    $FromCultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo($FromCulture)
    $ToCultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo($ToCulture)
    $Objects = Get-Item -Path $ObjectPath 
    $i = 0
    $count = $Objects.Count
    $StartTime = Get-Date
    foreach ($Object in $Objects) {
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
            Write-Progress -Status "Processing $i of $count" -Activity 'Converting objects...' -PercentComplete ($percent*100) -SecondsRemaining $remtime
        }
        $ObjectContent = (Get-Content -Path $Object.FullName -Encoding Oem) -split "`r`n"
        $ObjectDate = ($ObjectContent | Select -Index 4).Replace("[","").Replace("]","")    
        $ObjectTime = ($ObjectContent | Select -Index 5).Replace("[","").Replace("]","")    
        $NewDateTime = Get-Date
        if ([DateTime]::TryParse("$($ObjectDate.Substring(9,$ObjectDate.Length-10).Trim()) $($ObjectTime.Substring(9,$ObjectTime.Length-10).Trim())",$FromCultureInfo,[System.Globalization.DateTimeStyles]::None,[ref]$NewDateTime)) {
            $UpdatedObjectContent = $ObjectContent | Select -First 4
            $UpdatedObjectContent += $ObjectDate.SubString(0,9) + $NewDateTime.ToString($ToCultureInfo.DateTimeFormat.ShortDatePattern, $ToCultureInfo) + ";"
            $UpdatedObjectContent += $ObjectTime.SubString(0,9) + $NewDateTime.ToString($ToCultureInfo.DateTimeFormat.LongTimePattern, $ToCultureInfo) + ";"
            $UpdatedObjectContent += $ObjectContent | Select -Skip 6
            Set-Content -Path $Object.FullName -Value $UpdatedObjectContent -Force -Encoding Oem
        }
    }
}
