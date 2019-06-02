Function Get-NAVTranslationsFolderName()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InitialDirectory,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$Description = "Select Txt2AL Source Folder..."
    )
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $OpenFileDialog.Description = "Select Txt2AL Source Folder..."
    $OpenFileDialog.SelectedPath = $InitialDirectory
    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        return $OpenFileDialog.SelectedPath
    }
}