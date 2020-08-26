function Remove-OldInsiderDockerImages
{
    [CmdletBinding()]
    param()
    $images = docker images bcinsider --format "table {{.Repository}},{{.Tag}},{{.ID}},{{.Size}},{{.CreatedAt}}"
    $insiderImages = @()
    $imagesToRemove = @()
    $dateTimeFormat = 'yyyy-MM-dd HH:mm:ss'
    $images[1..$images.length] | % {
        $fields = $_.Split(",")
        $insiderImage = New-Object -TypeName PSObject
        $insiderImage | Add-Member -MemberType NoteProperty -Name Repository -Value $fields[0]
        $insiderImage | Add-Member -MemberType NoteProperty -Name Tag -Value $fields[1].Split("-")[0]
        $insiderImage | Add-Member -MemberType NoteProperty -Name Version -Value $fields[1].Split("-")[1]
        $insiderImage | Add-Member -MemberType NoteProperty -Name Major -Value $fields[1].Split("-")[1].Split(".")[0]
        $insiderImage | Add-Member -MemberType NoteProperty -Name Minor -Value $fields[1].Split("-")[1].Split(".")[1]
        $insiderImage | Add-Member -MemberType NoteProperty -Name Language -Value $fields[1].Split("-")[2]
        $insiderImage | Add-Member -MemberType NoteProperty -Name ID -Value $fields[2]
        $insiderImage | Add-Member -MemberType NoteProperty -Name Size -Value $fields[3]
        $insiderImage | Add-Member -MemberType NoteProperty -Name CreatedAt -Value ([DateTime]::ParseExact($fields[4].Substring(0,$dateTimeFormat.Length),$dateTimeFormat,$null))
        $insiderImages += $insiderImage
    }

    foreach ($insiderImage in ($insiderImages | Sort-Object -Property Version -Descending)) {
        $oldImages = $insiderImages | `
            Where-Object -Property Repository -eq $insiderImage.Repository | `
            Where-Object -Property Tag -EQ $insiderImage.Tag | `
            Where-Object -Property Major -EQ $insiderImage.Major | `
            Where-Object -Property Minor -EQ $insiderImage.Minor | `
            Where-Object -Property Language -EQ $insiderImage.Language | `
            Where-Object -Property Version -LT $insiderImage.Version
        $oldImages | % {
            if ($imagesToRemove -notcontains $($_.ID)) {
                $imagesToRemove += $($_.ID)
                Write-Host "Removing Docker Image $($_.ID)"
                try { docker image rm $($_.ID) }
                catch { Write-Host "Unable to remove Docker Image $($_.ID)" }
            }        
         }    
    }
}