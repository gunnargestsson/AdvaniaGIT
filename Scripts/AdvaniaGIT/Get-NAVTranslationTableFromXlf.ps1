Function Get-NAVTranslationTableFromXlf
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyname=$true)]
        [String]$XlfFile,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyname=$true)]
        [HashTable]$TranslateTable = @{}
    )

    Write-Host "Loading translation file ${XlfFile}..."
    if (!$TranslateTable) {$TranslateTable = @{}}
    [xml]$Xlf = Get-Content -Path $XlfFile -Encoding UTF8 
    foreach ($node in $Xlf.xliff.file.body.group.'trans-unit') {
        if ($node.target) {
            if (!($TranslateTable.ContainsKey($node.source))) {
                $TranslateTable.Add($node.source,$node.target)
            }
        }
    }
    return $TranslateTable
}
