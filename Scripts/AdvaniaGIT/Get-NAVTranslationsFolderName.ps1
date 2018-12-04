Function Get-NAVTranslationsFolderName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFileDialog.Description = "Select Txt2AL Source Folder..."
    $OpenFileDialog.SelectedPath = $initialDirectory
    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        return $OpenFileDialog.SelectedPath
    }
}