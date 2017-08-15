Function Get-InstalledLanguage
{
    param
    (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
    [PSObject]$SetupParameters
    )

    $Languages = (Get-ChildItem $SetupParameters.navServicePath -Filter '??-??' -Directory -ErrorAction SilentlyContinue) 
    if ($Languages) {
        $Language = $Languages[0].Name.SubString(3,2).ToUpper()
    } else { 
        $Language = (Get-Culture).Name.Substring(3,2).ToUpper()
    }
    return $Language
}
