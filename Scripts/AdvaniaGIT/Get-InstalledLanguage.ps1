Function Get-InstalledLanguage
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters
    )

    $Language = Get-NAVInstallationCountry -NavInstallationPath $SetupParameters.navServicePath
    if ([String]::IsNullOrEmpty($Language)) {
        $Language = Get-ReleaseForLocation -Location (Get-Culture).Name.Substring(3,2).ToUpper()
    } else {
        $Language = $Language.Substring(3,2).ToUpper()
    }
    return $Language
}
