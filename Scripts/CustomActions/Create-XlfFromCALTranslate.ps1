if ([String]::IsNullOrEmpty($SetupParameters.ALProjectList)) {
    $ALSolutions = @()
    $ALSolutions += Split-Path $SetupParameters.VSCodePath -Leaf
} else {
    $ALSolutions = $SetupParameters.ALProjectList
}

foreach ($ALSolution in $ALSolutions) {
    $TranslationFolder = Join-Path $SetupParameters.Repository "${ALSolution}\Translations"
    if (Test-Path $TranslationFolder) {
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
        $TranslationTarget = ($TranslationSource.FullName).Replace(".g.xlf",".${LanguageName}.xlf")
        if (Test-Path $TranslationTarget) {
            $TranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $TranslationTarget -TranslateTable $TranslationTable
            Remove-Item -Path $TranslationTarget -Force    
        }

        Write-Host "Select C/AL translation file to import..."
        $CALTranslationFile = Get-NAVTranslationFileName -initialDirectory $SetupParameters.Repository

        if ($CALTranslationFile) {
            if (Test-Path $CALTranslationFile) {
                $TranslationTable = Get-NAVTranslationTable -TranslationFile $CALTranslationFile -LanguageNo $LanguageId -TranslateTable $TranslationTable
            }
        }

        Write-Host "Select Txt2AL translation files path to import..."
        $Txt2ALTranslationFolder = Get-NAVTranslationsFolderName -initialDirectory $SetupParameters.Repository

        if ($Txt2ALTranslationFolder) {
            if (Test-Path $Txt2ALTranslationFolder -PathType Container) {
                $Txt2ALTranslationTargets = Get-ChildItem -Path $Txt2ALTranslationFolder -Filter "translation-${LanguageName}.xlf" -Recurse
                foreach ($Txt2ALTranslationTarget in $Txt2ALTranslationTargets) {
                    $TranslationTable = $TranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $Txt2ALTranslationTarget.FullName -TranslateTable $TranslationTable
                }
            }
        }


        if ($TranslationTable) {
            Copy-Item -Path $TranslationSource.FullName -Destination $TranslationTarget 
            Apply-NAVTranslationTableToXlfFile -TranslationTable $TranslationTable -XlfFile $TranslationTarget -TargetLanguage $LanguageName 
        } else {
            $TranslationTable = @{}
            Copy-Item -Path $TranslationSource.FullName -Destination $TranslationTarget 
            Apply-NAVTranslationTableToXlfFile -TranslationTable $TranslationTable -XlfFile $TranslationTarget -TargetLanguage $LanguageName 
        }
    }
}