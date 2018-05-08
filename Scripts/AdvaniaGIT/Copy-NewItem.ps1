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
        $DestinationItems = Get-ChildItem -Path $DestinationFolder
        $Difference = Compare-Object -ReferenceObject $SourceItems -DifferenceObject $DestinationItems
        $Difference | foreach {
            $copyParams = @{
                'Path' = $_.InputObject.FullName
            }
            if ($_.SideIndicator -eq '<=') {
                $copyParams.Destination = $DestinationFolder
            }
            Copy-Item @copyParams
        }
    }


}