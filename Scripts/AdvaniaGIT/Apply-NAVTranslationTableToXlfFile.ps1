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

    Write-Host "Loading translation file ${XlfFile}..."
    [xml]$Xlf = Get-Content -Path $XlfFile -Encoding UTF8 
    $Xlf.PreserveWhitespace = $true
    $Xlf.DocumentElement.file.SetAttribute('target-language',$TargetLanguage)
    $NoOfAlreadyTranslated = 0
    $NoOfAutomaticallyTranslated = 0
    $NoOfSetEqualToSource = 0
    foreach ($node in $Xlf.xliff.file.body.group.'trans-unit') {
        if ($node.target) {
            Write-Verbose "$($node.source) already translated"
            $NoOfAlreadyTranslated ++
        } else {
            if ($TranslationTable.ContainsKey($node.source)) {
                Write-Verbose "$($node.source) automatically translated"
                $target = $Xlf.CreateElement('target', $Xlf.DocumentElement.NamespaceURI)
                $target.InnerText = $TranslationTable.Item($node.source)
                $targetNode = $node.InsertBefore($target,$node.note[0])
                $NoOfAutomaticallyTranslated ++
            } else {
                Write-Verbose "no translation found for $($node.source)"
                $target = $Xlf.CreateElement('target', $Xlf.DocumentElement.NamespaceURI)
                $target.InnerText = $node.source
                $targetNode = $node.InsertBefore($target,$node.note[0])
                $NoOfSetEqualToSource ++
            }
        }
    }
    Write-Host " Already translated: $NoOfAlreadyTranslated `r`n Automatically translated: $NoOfAutomaticallyTranslated `r`n Set equal to source: $NoOfSetEqualToSource"
    Write-Host "Saving translation file ${XlfFile}..."
    $xlf.Save($XlfFile)
}
