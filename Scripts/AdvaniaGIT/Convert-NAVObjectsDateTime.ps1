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
    $Object = (Get-Content -Path $ObjectPath -Encoding Oem) -split "`r`n"
    $ObjectDate = ($Object | Select -Index 4).Replace("[","").Replace("]","")    
    $ObjectTime = ($Object | Select -Index 5).Replace("[","").Replace("]","")    
    $NewDateTime = Get-Date
    if ([DateTime]::TryParse("$($ObjectDate.Substring(9,$ObjectDate.Length-10).Trim()) $($ObjectTime.Substring(9,$ObjectTime.Length-10).Trim())",$FromCultureInfo,[System.Globalization.DateTimeStyles]::None,[ref]$NewDateTime)) {
        $UpdatedObject = $Object | Select -First 4
        $UpdatedObject += $ObjectDate.SubString(0,9) + $NewDateTime.ToString($ToCultureInfo.DateTimeFormat.ShortDatePattern, $ToCultureInfo) + ";"
        $UpdatedObject += $ObjectTime.SubString(0,9) + $NewDateTime.ToString($ToCultureInfo.DateTimeFormat.LongTimePattern, $ToCultureInfo) + ";"
        $UpdatedObject += $Object | Select -Skip 6
        Set-Content -Path $ObjectPath -Value $UpdatedObject -Force -Encoding Oem
    }
}
