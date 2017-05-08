Function Display-PatchDayNo
{
    $StartDate = [datetime]"2013-12-31"
    $EndData = (Get-Date)

    $TimeSpan = New-TimeSpan -Start $StartDate -End $EndData
    $a = new-object -comobject wscript.shell
    $b = $a.popup("NAV Version List Patch No. $($TimeSpan.Days)",5," This is a notification message for 5 seconds ",0)
}