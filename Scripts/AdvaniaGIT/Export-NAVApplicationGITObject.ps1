function Export-NAVApplicationGITObject
{
    [CmdletBinding(DefaultParameterSetName='All',SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        # Specifies the file to export to.
        [Parameter(Mandatory=$true, Position=1)]
        [string] $Path,
        # Specifies the filter that selects the objects to export.
        [string] $Filter,
        # Allows the command to skip application objects that are excluded from license, when exporting as txt.
        [Switch] $ExportTxtSkipUnlicensed,
        # Allows export with new syntax for TXT2AL conversion
        [Switch] $ExportWithNewSyntax
    )

    $skipUnlicensed = '0'
    if($ExportTxtSkipUnlicensed)
    {
        $skipUnlicensed = '1'
    }

    if ($ExportWithNewSyntax) {
        $command = "Command=ExportToNewSyntax`,ExportTxtSkipUnlicensed=$skipUnlicensed`,File=`"$Path`"" 
    } else {
        $command = "Command=ExportObjects`,ExportTxtSkipUnlicensed=$skipUnlicensed`,File=`"$Path`"" 
    }
    if($Filter)
    {
        $command = "$command`,Filter=`"$Filter`""
    }
    $logFile = Join-Path $SetupParameters.LogPath 'navexport.log'
    try
    {
        Run-NavIdeCommand -Command $command `
          -SetupParameters $SetupParameters `
          -BranchSettings $BranchSettings `
          -LogFile $logFile `
          -ErrText "Error while exporting $Filter" `
          -Verbose:$VerbosePreference

    }
    catch
    {
        Write-Error $_
    }
}
