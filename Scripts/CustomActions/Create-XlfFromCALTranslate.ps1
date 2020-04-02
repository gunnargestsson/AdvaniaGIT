$ALSolutions = Get-ALPaths -SetupParameters $SetupParameters

if ($SetupParameters.Languages -eq $null) {
    $Languages = @()
    $Language = New-Object -TypeName PSObject
    $Language | Add-Member -MemberType NoteProperty -Name Language -Value (Get-NAVTranslationTarget -SetupParameters $SetupParameters -BranchSettings $BranchSettings)
    $Languages += $Language
} else {
    $Languages = $SetupParameters.Languages
}

$PreviousLanguageName = "xx-YY"

foreach ($Language in $Languages) {
    $LanguageName = $Language.Language

    if ([string]::IsNullOrEmpty($LanguageName)) {
        Write-Host -ForegroundColor Red "Language not found or selected!"
        throw
    }
    
    if ($SetupParameters.xlfPath) {
        if (Test-Path $SetupParameters.xlfPath -PathType Container) {
            $Txt2ALTranslationTargets = Get-ChildItem -Path $SetupParameters.xlfPath -Filter "*${LanguageName}.xlf" -Recurse
            $ALTranslationTable = (New-Object System.Collections.Hashtable)
            foreach ($Txt2ALTranslationTarget in $Txt2ALTranslationTargets) {
                $ALTranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $Txt2ALTranslationTarget.FullName -TranslateTable $ALTranslationTable
            }
        }
    } else {
        $LanguageId = Get-NAVLanguageIdFromLanguageName -LanguageName $LanguageName

        if ($LanguageName.Substring(0,2) -eq $PreviousLanguageName.Substring(0,2)) {
            Write-Host "Using Previous Language Data..."
        } else {
            Write-Host "Select ${LanguageName} C/AL translation file to import..."
            $CALTranslationFile = Get-NAVTranslationFileName -initialDirectory $SetupParameters.Repository

            if ($CALTranslationFile) {
                if (Test-Path $CALTranslationFile) {
                    $CALTranslationTable = Get-NAVTranslationTable -TranslationFile $CALTranslationFile -LanguageNo $LanguageId -TranslateTable (New-Object System.Collections.Hashtable) -SaveToCSV
                }
            }

            Write-Host "Select ${LanguageName} Txt2AL translation files path to import..."
            $Txt2ALTranslationFolder = Get-NAVTranslationsFolderName -initialDirectory $SetupParameters.Repository

            if ($Txt2ALTranslationFolder) {
                if (Test-Path $Txt2ALTranslationFolder -PathType Container) {
                    $Txt2ALTranslationTargets = Get-ChildItem -Path $Txt2ALTranslationFolder -Filter "*${LanguageName}.xlf" -Recurse
                    $ALTranslationTable = @{}
                    foreach ($Txt2ALTranslationTarget in $Txt2ALTranslationTargets) {
                        $ALTranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $Txt2ALTranslationTarget.FullName -TranslateTable $ALTranslationTable
                    }
                }
            }

        }
        $PreviousLanguageName = $LanguageName
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
                $PreviousTranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $TranslationTarget -TranslateTable (New-Object System.Collections.Hashtable)
                Remove-Item -Path $TranslationTarget -Force    
            } else {
                $PreviousTranslationTable = $null
            }
             
            Copy-Item -Path $TranslationSource.FullName -Destination $TranslationTarget
            if ($PreviousTranslationTable) {
                Write-Host "Adding Previous Translations..."
                Apply-NAVTranslationTableToXlfFile -TranslationTable $PreviousTranslationTable -XlfFile $TranslationTarget -TargetLanguage $LanguageName
            }
            if ($ALTranslationTable) {
                Write-Host "Adding AL Translations..."
                Apply-NAVTranslationTableToXlfFile -TranslationTable $ALTranslationTable -XlfFile $TranslationTarget -TargetLanguage $LanguageName
            }
            if ($CALTranslationTable) {
                Write-Host "Adding C/AL Translations..."
                Apply-NAVTranslationTableToXlfFile -TranslationTable $CALTranslationTable -XlfFile $TranslationTarget -TargetLanguage $LanguageName
            }

        }
    }
}