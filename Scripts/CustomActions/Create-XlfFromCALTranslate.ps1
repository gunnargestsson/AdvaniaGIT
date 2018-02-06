$TranslationFolder = Join-Path $SetupParameters.Repository "AL\Translations"
$TranslationSource = Get-ChildItem -Path $TranslationFolder -Filter '*.g.xlf' -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($TranslationSource)) {
    Write-Host -ForegroundColor Red "Unable to locate a translation source file in folder ${TranslationFolder}"
    throw
}

$LanguageName = Get-NAVTranslationTarget -SetupParameters $SetupParameters
if ([string]::IsNullOrEmpty($LanguageName)) {
    Write-Host -ForegroundColor Red "Language not found or selected!"
    throw
}

$LanguageId = Get-NAVLanguageIdFromLanguageName -LanguageName $LanguageName
$TranslationTarget = ($TranslationSource.FullName).Replace(".g.xlf",".${LanguageId}.xlf")
if (Test-Path $TranslationTarget) {
    Write-Host -ForegroundColor Red "Translation Target Language already exists.  Please delete file and try again"
    throw
}

$CALTranslationFile = Get-NAVTranslationFileName -initialDirectory $SetupParameters.Repository

if (!(Test-Path $CALTranslationFile)) {
    Write-Host -ForegroundColor Red "CAL Translation file not found!"
    throw
}


Copy-Item -Path $TranslationSource.FullName -Destination $TranslationTarget 
$TranslationTable = Get-NAVTranslationTable -TranslationFile $CALTranslationFile -LanguageNo $LanguageId 
Apply-NAVTranslationTableToXlfFile -TranslationTable $TranslationTable -XlfFile $TranslationTarget -TargetLanguage $LanguageName 