Function Copy-NewItem 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$SourceFolder,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$DestinationFolder
    )
    if ((Test-Path -Path $SourceFolder -PathType Container) -and (Test-Path -Path $DestinationFolder -PathType Container)) {
        $SourceItems = Get-ChildItem -Path $SourceFolder
        foreach ($sourceItem in $SourceItems) {
            $DestinationItem = Join-Path $DestinationFolder $sourceItem.Name
            if (!(Test-Path -Path $DestinationItem)) {
                Write-Host "Copying $($sourceItem.Name)..."
                Copy-Item $sourceItem.FullName -Destination $DestinationFolder
            }
        }
    }


}