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
        if ($node.translate -ieq 'yes') {
            if ($node.target) {
                if (!($TranslateTable.ContainsKey($node.source))) {
                    if ($node.target.GetType().Name -eq "String") {
                        if (![string]::IsNullOrEmpty($node.target)) {
                            $TranslateTable.Add($node.source,$node.target)
                        }
                    } else {
                        if (![string]::IsNullOrEmpty($node.target.'#text')) {
                            $TranslateTable.Add($node.source,$node.target.'#text')
                        }
                    }
                }
            }
        }
    }
    return $TranslateTable
}
