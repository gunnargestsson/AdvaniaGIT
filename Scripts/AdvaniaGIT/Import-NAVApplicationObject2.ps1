<#
    .SYNOPSIS
    Imports NAV application objects from a file into a database.

    .DESCRIPTION
    The Import-NAVApplicationObject function imports the objects from the specified file(s) into the specified database. When multiple files are specified, finsql is invoked for each file. For better performance the files can be joined first. However, using seperate files can be useful for analyzing import errors.

    .INPUTS
    System.String[]
    You can pipe a path to the Import-NavApplicationObject function.

    .OUTPUTS
    None

    .EXAMPLE
    Import-NAVApplicationObject MyAppSrc.txt MyApp
    This command imports all application objects in MyAppSrc.txt into the MyApp database.

    .EXAMPLE
    Import-NAVApplicationObject MyAppSrc.txt -DatabaseName MyApp
    This command imports all application objects in MyAppSrc.txt into the MyApp database.

    .EXAMPLE
    Get-ChildItem MyAppSrc | Import-NAVApplicationObject -DatabaseName MyApp
    This commands imports all objects in all files in the MyAppSrc folder into the MyApp database. The files are imported one by one.

    .EXAMPLE
    Get-ChildItem MyAppSrc | Join-NAVApplicationObject -Destination .\MyAppSrc.txt -PassThru | Import-NAVApplicationObject -Database MyApp
    This commands joins all objects in all files in the MyAppSrc folder into a single file and then imports them in the MyApp database.
    Kamil Sacek
#>
function Import-NAVApplicationObject2
{
    [CmdletBinding(DefaultParameterSetName='All', SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param(
        # Specifies one or more files to import.  
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]] $Path,

        # Specifies the name of the database into which you want to import.
        [Parameter(Mandatory=$true, Position=1)]
        [string] $DatabaseName,

        # Specifies the name of the SQL server instance to which the database you want to import into is attached. The default value is the default instance on the local host (.).
        [ValidateNotNullOrEmpty()]
        [string] $DatabaseServer = '.',

        # Specifies the log folder.
        [ValidateNotNullOrEmpty()]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",

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

        # Specifies the name of the server that hosts the Microsoft Dynamics NAV Server instance, such as MyServer.
        [string] $NavServerName,

        # Specifies the Microsoft Dynamics NAV Server instance that is being used.The default value is DynamicsNAV80.
        [string] $NavServerInstance = 'DynamicsNAV80',

        # Specifies the port on the Microsoft Dynamics NAV Server server that the Microsoft Dynamics NAV Windows PowerShell cmdlets access. The default value is 7045.
        [ValidateNotNullOrEmpty()]
        [int16]  $NavServerManagementPort = 7045)
    BEGIN
    {
        #Import-Module CommonPSFunctions
    }
    PROCESS
    {
        if ($Path.Count -eq 1)
        {
            $Path = (Get-Item $Path).FullName
        }

        if ($True)
        {
            foreach ($file in $Path)
            {
                Write-Verbose -Message "Importing $file on $NavServerName : $NavServerManagementPort/$NavServerInstance"
                # Log file name is based on the name of the imported file.
                $logFile = "$LogPath\$((Get-Item $file).BaseName).log"             
                $command = "Command=ImportObjects`,ImportAction=$ImportAction`,SynchronizeSchemaChanges=$SynchronizeSchemaChanges`,File=`"$file`""                 

                try
                {
                    Run-NavIdeCommandWithParam -Command $command `
                                      -DatabaseServer $DatabaseServer `
                                      -DatabaseName $DatabaseName `
                                      -NTAuthentication:($Username -eq $null) `
                                      -Username $Username `
                                      -Password $Password `
                                      -NavServerInfo $navServerInfo `
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
    }
}
