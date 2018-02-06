Function Get-NAVTranslationTable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyname=$true)]
        [String]$TranslationFile,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyname=$true)]
        [String]$LanguageNo
    )

    Write-Host "Loading translation data from ${TranslationFile}..."
    $CALTranslateFile = Get-Content -Encoding Oem -Path $TranslationFile
    $LanguageNo = '-A' + $LanguageNo
    $TranslateTable = @{}
    $keyFound = $false
    $NoOfLines = 0
    foreach ($CALTranslateLine in $CALTranslateFile) {    
        $index = $CALTranslateLine.Split(':')[0]
        if ($keyFound -and $CALTranslateLine -match $LanguageNo) {
            $object= $CALTranslateLine.Split(':')[0]
            $pos = $object.IndexOf('-A')
            $object = $object.Substring($pos + 2)
            $pos = $object.IndexOf('-')
            $object = $object.Substring(0,$pos - 1)
            $TranslateTable.Add($Key,$CALTranslateLine.Split(':')[1])
            $NoOfLines ++
        } 
        $keyFound = $false
        if ($index -match '-A1033') {        
            $key = $CALTranslateLine.Split(':')[1]
            $keyFound = !($TranslateTable.ContainsKey($key))
        }
    }
    Write-Host "${NoOfLines} lines loaded in memory!"
    return $TranslateTable    
}
