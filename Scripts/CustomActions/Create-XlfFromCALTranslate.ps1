$TranslationFolder = Join-Path $SetupParameters.Repository "AL\Translations"
$TranslationSource = Get-ChildItem -Path $TranslationFolder -Filter '*.g.xlf' -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($TranslationSource)) {
    Write-Host -ForegroundColor Red "Unable to locate a translation source file in folder ${TranslationFolder}"
    throw
}

$LanguageName = Get-NAVTranslationTarget -SetupParameters $SetupParameters -BranchSettings $BranchSettings
if ([string]::IsNullOrEmpty($LanguageName)) {
    Write-Host -ForegroundColor Red "Language not found or selected!"
    throw
}

$LanguageId = Get-NAVLanguageIdFromLanguageName -LanguageName $LanguageName
$TranslationTarget = ($TranslationSource.FullName).Replace(".g.xlf",".${LanguageId}.xlf")
if (Test-Path $TranslationTarget) {
    $TranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $TranslationTarget -TranslateTable $TranslationTable
    Remove-Item -Path $TranslationTarget -Force    
}

Write-Host "Select C/AL translation file to import..."
$CALTranslationFile = Get-NAVTranslationFileName -initialDirectory $SetupParameters.Repository

if (Test-Path $CALTranslationFile) {
    $TranslationTable = Get-NAVTranslationTable -TranslationFile $CALTranslationFile -LanguageNo $LanguageId -TranslateTable $TranslationTable
}

if ($TranslationTable) {
    Copy-Item -Path $TranslationSource.FullName -Destination $TranslationTarget 
    Apply-NAVTranslationTableToXlfFile -TranslationTable $TranslationTable -XlfFile $TranslationTarget -TargetLanguage $LanguageName 
}