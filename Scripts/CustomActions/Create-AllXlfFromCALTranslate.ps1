$ALSolutions = Get-ALPaths -SetupParameters $SetupParameters
$Languages = Get-NAVTranslationTargets -SetupParameters $SetupParameters -BranchSettings $BranchSettings
$CALTranslationFolder = Get-NAVTranslationsFolderName -InitialDirectory $SetupParameters.Workfolder -Description "Select folder with FinSql Translation export"


foreach ($ALSolution in $ALSolutions) {
    Write-Host "Solution: $($ALSolution.BaseName)..."
    $TranslationFolder = Join-Path $ALSolution.FullName "Translations"
    $NewTranslationFolder = Join-Path $ALSolution.FullName "NewTranslations" 
    New-Item -Path $NewTranslationFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

    if (Test-Path $TranslationFolder) {
        $TranslationSource = Get-ChildItem -Path $TranslationFolder -Filter '*.g.xlf' -ErrorAction SilentlyContinue
        if ([string]::IsNullOrEmpty($TranslationSource)) {
            Write-Host -ForegroundColor Red "Unable to locate a translation source file in folder ${TranslationFolder}"
            throw
        }

        foreach ($LanguageName in $Languages.Name) {
            $TranslateTable = (New-Object System.Collections.Hashtable)

            $LanguageId = Get-NAVLanguageIdFromLanguageName -LanguageName $LanguageName
            $CountryId = $LanguageName.substring(3,2)
            if ($CountryId -in ("CA","US","MX")) { $CountryId = "NA" }
            
            $CALTranslationCSVFile = Join-Path $CALTranslationFolder "${LanguageName}.csv"
            if (Test-Path -Path $CALTranslationCSVFile) {
                Write-Host "Reading CAL translation from CSV..."
                $TranslateTable = Import-Csv -Path $CALTranslationCSVFile
            } else {
                $CALTranslationFile = Join-Path $CALTranslationFolder "${CountryId}.txt"
                if (Test-Path -Path $CALTranslationFile) {
                    Write-Host "Reading CAL translation..."
                    $TranslationTable = Get-NAVTranslationTable -TranslationFile $CALTranslationFile -LanguageNo $LanguageId -TranslateTable $TranslateTable
                    $TranslationTable | Out-File $CALTranslationCSVFile
                } 
            }
            $NewTranslationTarget = Join-Path $NewTranslationFolder ($TranslationSource.Name).Replace(".g.xlf",".${LanguageName}.xlf")
            $TranslationTarget = ($TranslationSource.FullName).Replace(".g.xlf",".${LanguageName}.xlf")
            if (Test-Path $TranslationTarget) {
                Write-Host "Reading Xlf translation..."
                $TranslationTable = Get-NAVTranslationTableFromXlf -XlfFile $TranslationTarget -TranslateTable $TranslationTable
            }

            if ($TranslationTable) {
                Copy-Item -Path $TranslationSource.FullName -Destination $NewTranslationTarget 
                Apply-NAVTranslationTableToXlfFile -TranslationTable $TranslationTable -XlfFile $NewTranslationTarget -TargetLanguage $LanguageName 
            } else {
                $TranslationTable = @{}
                Copy-Item -Path $TranslationSource.FullName -Destination $NewTranslationTarget 
                Apply-NAVTranslationTableToXlfFile -TranslationTable $TranslationTable -XlfFile $NewTranslationTarget -TargetLanguage $LanguageName 
            }
        }
    }
}