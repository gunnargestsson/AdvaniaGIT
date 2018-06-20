function Invoke-NAVDatabaseSymbolReferenceUpdate
{
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $Username,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string] $Password               
    )

    $logFile = (Join-Path $SetupParameters.LogPath naverrorlog.txt)

    $command = 'Command=generatesymbolreference'
    
    Run-NavIdeCommand -Command $command `
        -SetupParameters $SetupParameters `
        -BranchSettings $BranchSettings `
        -UserName $UserName `
        -Password $Password `
        -LogFile $logFile `
        -ErrText "Error while converting $($BranchSettings.DatabaseName)" `
        -Verbose:$VerbosePreference `
        -StopOnError

}
