function Import-NAVApplicationGITObject
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
            
    Write-Verbose -Message "Importing from $(Split-Path $path) on $($BranchSettings.managementPort)/$($BranchSettings.instanceName)"
    # Log file name is based on the name of the imported file.
    $logFile = (Join-Path $SetupParameters.LogPath "navimport.log")
    $command = "Command=ImportObjects`,ImportAction=$ImportAction`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges`,File=`"$Path`""                 
    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 11) {
      $command += ",generatesymbolreference=1"
    }
    try
    {
        if (![String]::IsNullOrEmpty($SetupParameters.dockerAuthentication) -and $SetupParameters.dockerAuthentication -ieq "NavUserPassword") {
            $DockerCredentials = Get-DockerAdminCredentials -Message "Enter credentials for the Docker Container" -DefaultUserName $env:USERNAME
            Run-NavIdeCommand -Command $command `
                -SetupParameters $SetupParameters `
                -BranchSettings $BranchSettings `
                -LogFile $logFile `
                -ErrText "Error while importing from $(Split-Path $Path)" `
                -Verbose:$VerbosePreference `
                -Username $DockerCredentials.UserName `
                -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DockerCredentials.Password)))
        } else {
            Run-NavIdeCommand -SetupParameters $SetupParameters `
                -BranchSettings $BranchSettings `
                -Command $command `
                -LogFile $logFile `
                -ErrText "Error while importing from $(Split-Path $Path)" `
                -Verbose:$VerbosePreference
        }
    }
    catch
    {
        Write-Error $_
        throw
    }

}
