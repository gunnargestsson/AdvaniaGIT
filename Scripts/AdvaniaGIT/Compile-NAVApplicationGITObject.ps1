function Compile-NAVApplicationGITObject
{
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory = $true,ValueFromPipelinebyPropertyName = $true)]
        [String]$Filter,
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [switch]$AsJob,
        # Specifies the schema synchronization behaviour. The default value is 'Yes'.
        [Parameter(ValueFromPipelinebyPropertyName = $true)]
        [ValidateSet('Yes','No','Force')]
        [string] $SynchronizeSchemaChanges = 'Yes'
    )
    $LogFile = "$LogPath\filtercompile.log"
    $command = "Command=CompileObjects`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges`,Filter=`"$Filter`""
    Run-NavIdeCommand -SetupParameters $SetupParameters `
                    -BranchSettings $BranchSettings `
                    -Command $command `
                    -LogFile $logFile `
                    -ErrText "Error while importing $file" `
                    -Verbose:$VerbosePreference
   

    if (Test-Path -Path "$LogPath\navcommandresult.txt")
    {
        Write-Verbose -Message "Processed $Filter."
        Remove-Item -Path "$LogPath\navcommandresult.txt"
    }
    else
    {
        Write-Error -Message "Crashed when compiling $Filter !"
    }

    If (Test-Path -Path "$LogFile") 
    {
        Convert-NAVLogFileToErrors -LogFile $LogFile
    }
}
