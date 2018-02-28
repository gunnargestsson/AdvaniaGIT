Function Display-PatchDayNo
{
    $StartDate = [datetime]"2013-12-31"
    $EndData = (Get-Date)

    $TimeSpan = New-TimeSpan -Start $StartDate -End $EndData

    if ($env:TERM_PROGRAM -eq $null) {
        $a = new-object -comobject wscript.shell
        $b = $a.popup("NAV Version List Patch No. $($TimeSpan.Days)",5," This is a notification message for 5 seconds ",0)
    } else {
        Write-Host "**** NAV Version List Patch No. $($TimeSpan.Days) ****"
    }
}