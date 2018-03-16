function Get-NAVLanguageIdFromLanguageName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$LanguageName
    )

    $CultureInfos = [System.Globalization.Cultureinfo]::GetCultures("AllCultures")
    return ($CultureInfos | Where-Object -Property Name -ieq $LanguageName).LCID
}
