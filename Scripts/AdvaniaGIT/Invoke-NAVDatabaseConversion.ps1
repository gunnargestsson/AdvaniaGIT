<#
    .SYNOPSIS
    Performs a technical upgrade of a database from a previous version of Microsoft Dynamics NAV.

    .DESCRIPTION
    Performs a technical upgrade of a database from a previous version of Microsoft Dynamics NAV.

    .INPUTS
    None
    You cannot pipe input into this function.

    .OUTPUTS
    None

    .EXAMPLE
    Invoke-NAVDatabaseConversion MyApp
    Perform the technical upgrade on a NAV database named MyApp.

    .EXAMPLE
    Invoke-NAVDatabaseConversion MyApp -ServerName "TestComputer01\NAVDEMO"
    Perform the technical upgrade on a NAV database named MyApp on TestComputer01\NAVDEMO Sql server .
#>
function Invoke-NAVDatabaseConversion
{
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings       
    )

    $logFile = (Join-Path $SetupParameters.LogPath naverrorlog.txt)

    $command = 'Command=UpgradeDatabase'
    
    Run-NavIdeCommand -Command $command `
        -SetupParameters $SetupParameters `
        -BranchSettings $BranchSettings `
        -LogFile $logFile `
        -ErrText "Error while converting $($BranchSettings.DatabaseName)" `
        -Verbose:$VerbosePreference `
        -StopOnError

}
