Function Apply-NAVTranslationTableToXlfFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyname=$true)]
        [hashtable]$TranslationTable, 
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyname=$true)]
        [String]$XlfFile,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyname=$true)]
        [String]$TargetLanguage
    )

    Write-Host "Updating translation file ${XlfFile}..."
    [xml]$Xlf = Get-Content -Path $XlfFile -Encoding UTF8 
    $Xlf.PreserveWhitespace = $true
    $Xlf.DocumentElement.file.SetAttribute('target-language',$TargetLanguage)
    $NoOfAlreadyTranslated = 0
    $NoOfAutomaticallyTranslated = 0
    $NoOfNeedsTranslation = 0
    $NoOfNotToBeTranslated = 0
    foreach ($node in $Xlf.xliff.file.body.group.'trans-unit') {
        if ($node.translate -ieq 'no') {
            Write-Verbose "$($node.source) should not be translated"
            $NoOfNotToBeTranslated ++
        } elseif ($node.translate -ieq 'yes') {
            if ($node.target) {
                Write-Verbose "$($node.source) already translated"
                $NoOfAlreadyTranslated ++
            } else {
                if ($TranslationTable.ContainsKey($node.source)) {
                    Write-Verbose "$($node.source) automatically translated"
                    $target = $Xlf.CreateElement('target', $Xlf.DocumentElement.NamespaceURI)
                    $target.InnerText = $TranslationTable.Item($node.source)
                    $target.SetAttribute('state','translated')
                    $targetNode = $node.InsertBefore($target,$node.note[0])
                    $NoOfAutomaticallyTranslated ++
                } elseif ($Xlf.DocumentElement.file.'source-language'.Substring(0,2) -eq $TargetLanguage.Substring(0,2)) {
                    Write-Verbose "$($node.source) automatically translated"
                    $target = $Xlf.CreateElement('target', $Xlf.DocumentElement.NamespaceURI)
                    $target.InnerText = $node.source
                    $target.SetAttribute('state','translated')
                    $targetNode = $node.InsertBefore($target,$node.note[0])
                    $NoOfAutomaticallyTranslated ++
                } else {
                    Write-Verbose "no translation found for $($node.source)"
                    $NoOfNeedsTranslation ++
                }
            }
        }
    }
    Write-Host " Already translated: $NoOfAlreadyTranslated `r`n Automatically translated: $NoOfAutomaticallyTranslated `r`n Needs translation: $NoOfNeedsTranslation `r`n Not to be translated: $NoOfNotToBeTranslated"
    Write-Host "Saving translation file ${XlfFile}..."
    $xlf.Save($XlfFile)
}
