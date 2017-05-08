function Import-NAVApplicationObject
{
    [CmdletBinding(DefaultParameterSetName='All', SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        # Specifies one or more files to import.  
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]] $Path,
        # Specifies the import action. The default value is 'Default'.
        [ValidateSet('Default','Overwrite','Skip')] [string] $ImportAction = 'Default',
        # Specifies the schema synchronization behaviour. The default value is 'Yes'.
        [ValidateSet('Yes','No','Force')] [string] $SynchronizeSchemaChanges = 'Yes'
    )
    
    if ($Path.Count -eq 1)
    {
        $Path = (Get-Item $Path).FullName
    }

    foreach ($file in $Path)
    {
        Write-Verbose -Message "Importing $file on $($BranchSettings.managementPort)/$($BranchSettings.instanceName)"
        # Log file name is based on the name of the imported file.
        $logFile = (Join-Path $LogPath (Get-Item $file).BaseName) + ".log"            
        $command = "Command=ImportObjects`,ImportAction=$ImportAction`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges`,File=`"$file`""                 

        try
        {
            Run-NavIdeCommand -SetupParameters $SetupParameters `
                                -BranchSettings $BranchSettings `
                                -Command $command `
                                -LogFile $logFile `
                                -ErrText "Error while importing $file" `
                                -Verbose:$VerbosePreference
        }
        catch
        {
            Write-Error $_
        }
    }
}
