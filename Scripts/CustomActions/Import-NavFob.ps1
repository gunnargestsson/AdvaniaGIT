param(
        [Parameter(Mandatory=$false)]
        [string] $DatabaseName,

        # Specifies the name of the SQL server instance to which the database you want to import into is attached. The default value is the default instance on the local host (.).
        [Parameter(Mandatory=$false)]
        [string] $DatabaseServer = '.',

        # Specifies the log folder.
        [Parameter(Mandatory=$false)]
        [string] $LogPath = "$Env:TEMP\NavIde\$([GUID]::NewGuid().GUID)",
        # Specifies the name of the server that hosts the Microsoft Dynamics NAV Server instance, such as MyServer.
        [Parameter(Mandatory=$false)]
        [string] $NavServerName,

        # Specifies the Microsoft Dynamics NAV Server instance that is being used.The default value is DynamicsNAV80.
        [Parameter(Mandatory=$false)]
        [string] $NavServerInstance = 'DynamicsNAV80',

        # Specifies the port on the Microsoft Dynamics NAV Server server that the Microsoft Dynamics NAV Windows PowerShell cmdlets access. The default value is 7045.
        [Parameter(Mandatory=$false)]
        [int16]  $NavServerManagementPort = 7045,
        [string] $Path=''
)
if (-not $Path) {
    if ($env:bamboo_build_working_directory) {
        $ObjectFileName = (Join-Path $env:bamboo_build_working_directory 'AllObjects.fob')
    } else {
        $ObjectFileName = (Join-Path $SetupParameters.workFolder 'AllObjects.fob')
    }
} else {
    $ObjectFileName = $Path
}
if ($BranchSettings) {
    $DatabaseName = $BranchSettings.databaseName
    $DatabaseServer = Get-DatabaseServer -BranchSettings $BranchSettings
    $NavServerName = '.'
    $NavServerInstance = $BranchSettings.instanceName
    $NavServerManagementPort = $BranchSettings.managementServicesPort
}

if (-not $DatabaseName) {
    $DatabaseName = $env:DatabaseName
    $DatabaseServer = $env:DatabaseServer
    $NavServerInstance = ''  
}
Write-Host -Object "Importing all objects from $ObjectFileName to $DatabaseServer Db=$DatabaseName..."            
$Username = $env:bamboo_AzureDB_Username
$Password = $env:bamboo_AzureDB_Password
Import-NAVApplicationObject2 -Path $ObjectFileName -DatabaseName $DatabaseName -DatabaseServer $DatabaseServer -LogPath $LogPath -NavServerName $NavServerName -NavServerInstance $NavServerInstance -NavServerManagementPort $NavServerManagementPort -ImportAction Overwrite -SynchronizeSchemaChanges No -Username $Username -Password $Password -ErrorAction Stop
Write-Host -Object "Import from $ObjectFileName completed"
