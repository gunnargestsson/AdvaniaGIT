function Get-DefaultInstanceLanguage
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters
    )
    
    $Language = (Get-ChildItem -Path $SetupParameters.navServicePath -Filter '??-??' -Directory)
    if ($Language) {
        Return ($Language | Select-Object -First 1).Name
    } else {
        Return "en-US"
    }
}