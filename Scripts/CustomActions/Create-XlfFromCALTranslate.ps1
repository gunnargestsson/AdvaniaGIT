$ALSolutions = Get-ALPaths -SetupParameters $SetupParameters

if ($SetupParameters.Languages -eq $null) {
    $Languages = @()
    $Language = New-Object -TypeName PSObject
    $Language | Add-Member -MemberType NoteProperty -Name Language -Value (Get-NAVTranslationTarget -SetupParameters $SetupParameters -BranchSettings $BranchSettings)
    $Languages += $Language
} else {
    $Languages = $SetupParameters.Languages
}

foreach ($Language in $Languages) {
    $LanguageName = $Language.Language
    $TranslationTable = $null

    if ([string]::IsNullOrEmpty($LanguageName)) {
        Write-Host -ForegroundColor Red "Language not found or selected!"
        throw
    }
    $LanguageId = Get-NAVLanguageIdFromLanguageName -LanguageName $LanguageName

    Write-Host "Select ${LanguageName} C/AL translation file to import..."
    $CALTranslationFile = Get-NAVTranslationFileName -initialDirectory $SetupParameters.Repository

    if ($CALTranslationFile) {
        if (Test-Path $CALTranslationFile) {
            $TranslationTable = Get-NAVTranslationTable -TranslationFile $CALTranslationFile -LanguageNo $LanguageId -TranslateTable $TranslationTable
        }
    }

    Write-Host "Select ${LanguageName} Txt2AL translation files path to import..."
    $Txt2ALTranslationFolder = Get-NAVTranslationsFolderName -initialDirectory $SetupParameters.Repository

    if ($Txt2ALTranslationFolder) {
        if (Test-Path $Txt2ALTranslationFolder -PathType Container) {
            $Txt2ALTranslationTargets = Get-ChildItem -Path $Txt2ALTranslationFolder -Filter "*${LanguageName}.xlf" -Recurse
            foreach ($Txt2ALTranslationTarget in $Txt2ALTranslationTargets) {
                $TranslationTable = $TranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $Txt2ALTranslationTarget.FullName -TranslateTable $TranslationTable
            }
        }
    }

    foreach ($ALSolution in $ALSolutions) {
        Write-Host "Solution: $($ALSolution.BaseName)..."
        $TranslationFolder = Join-Path $ALSolution.FullName "Translations"
        if (Test-Path $TranslationFolder) {
            $TranslationSource = Get-ChildItem -Path $TranslationFolder -Filter '*.g.xlf' -ErrorAction SilentlyContinue
            if ([string]::IsNullOrEmpty($TranslationSource)) {
                Write-Host -ForegroundColor Red "Unable to locate a translation source file in folder ${TranslationFolder}"
                throw
            }

            $TranslationTarget = ($TranslationSource.FullName).Replace(".g.xlf",".${LanguageName}.xlf")
            if (Test-Path $TranslationTarget) {
                $TranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $TranslationTarget -TranslateTable $TranslationTable
                Remove-Item -Path $TranslationTarget -Force    
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
}