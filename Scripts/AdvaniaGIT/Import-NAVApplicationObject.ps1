function Import-NAVApplicationObject
{
    [CmdletBinding(DefaultParameterSetName='All',SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        # Specifies the import action. The default value is 'Default'.
        [ValidateSet('Default','Overwrite','Skip')] [string] $ImportAction = 'Default',

        # Specifies the schema synchronization behaviour. The default value is 'Yes'.
        [ValidateSet('Yes','No','Force')] [string] $SynchronizeSchemaChanges = 'Yes',

        # The user name to use to authenticate to the database. The user name must exist in the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName='DatabaseAuthentication')]
        [string] $Username,

        # The password to use with the username parameter to authenticate to the database. If you do not specify a user name and password, then the command uses the credentials of the current Windows user to authenticate to the database.
        [Parameter(Mandatory=$true, ParameterSetName='DatabaseAuthentication')]
        [string] $Password,
        # Specifies the file to export to.
        [Parameter(Mandatory=$true, Position=1)]
        [string] $Path
    )

    $command = "Command=ImportObjects`,ImportAction=$ImportAction`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges`,File=`"$Path`"" 
    $logFile = Join-Path $SetupParameters.LogPath 'navexport.log'
    try
    {
        Run-NavIdeCommand -Command $command `
          -SetupParameters $SetupParameters `
          -BranchSettings $BranchSettings `
          -LogFile $logFile `
          -ErrText "Error while exporting $Filter" `
          -Verbose:$VerbosePreference `
          -Username $Username `
          -Passw

    }
    catch
    {
        Write-Error $_
    }
}
