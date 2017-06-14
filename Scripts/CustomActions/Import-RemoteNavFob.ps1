<#
$SetupParameters
    RemotePath = Workfolder on Remote Machine, default C:\AdvaniaGIT\Workspace.  Will be removed and recreated
    WorkFolder = Worlfolder on Local Machine, default to build folder
    ftpServer = ftp server name, default ftp://ftp02.hysing.is/
    ftpUser = username for ftp server
    ftpPass = password for ftp user
    navServicePath = path to NAV service, default C:\Program Files\Microsoft Dynamics NAV\100\Service
    RemoteServerName = FDQN for the Remote Server.  Connection made via secure powershell port 5986
    RemoteUserName = Administrator user on the Remote Server
    RemotePassword = Plain Text password for administration user on Remote Server
    RemoteDatabaseName = Database Name as seen from the Remote Server
    RemoteDatabaseServerName = Database Server Name as seen from the Remote Server


#>
try {
    $RemoteFile = Join-Path $SetupParameters.RemotePath 'archive.zip'
    $LocalArchive = Join-Path $env:Temp (Split-Path $RemoteFile -Leaf)   
    $TargetFolder = $SetupParameters.RemotePath
    Add-Type -assembly 'system.io.compression.filesystem'

    Remove-Item $LocalArchive -Force -ErrorAction SilentlyContinue| Out-Null
    Write-Verbose 'Compressing the file'
    [io.compression.zipfile]::CreateFromDirectory($SetupParameters.WorkFolder,$LocalArchive)
    Put-FtpFile -Server $SetupParameters.ftpServer -User $SetupParameters.ftpUser -Pass $SetupParameters.ftpPass -FtpFilePath (Split-Path $RemoteFile -Leaf) -LocalFilePath $LocalArchive
    Remove-Item -Path $LocalArchive -Force | Out-Null

    $RemoveAdminModelePath = Join-Path $SetupParameters.navServicePath "Microsoft.Dynamics.Nav.Management.dll"
    Write-Verbose "Opening Session on $($SetupParameters.RemoteServerName) as user $($SetupParameters.RemoteUserName)..."
    $session = Invoke-RemoteCommand -Command "import-module `"$RemoveAdminModelePath`"" -VMAdminUserName $SetupParameters.RemoteUserName -VMAdminPassword $SetupParameters.RemotePassword -VMURL $SetupParameters.RemoteServerName
    Write-Verbose 'Copying file to remote machine'
    Invoke-RemoteCommand -Command "remove-item '$(Split-Path -Path $RemoteFile -Parent)' -Recurse -Force -ErrorAction SilentlyContinue" -PSSession $session | Out-Null
    Invoke-RemoteCommand -Command "New-Item -Path '$(Split-Path -Path $RemoteFile -Parent)' -ItemType Directory -ErrorAction SilentlyContinue" -PSSession $session | Out-Null    
    Invoke-RemoteCommand -Command "Get-FtpFile -Server $($SetupParameters.ftpServer) -User $($SetupParameters.ftpUser) -Pass $($SetupParameters.ftpPass) -FtpFilePath $(Split-Path $RemoteFile -Leaf) -LocalFilePath '$RemoteFile'" -PSSession $session | Out-Null
    Invoke-RemoteCommand -Command "Add-Type -assembly 'system.io.compression.filesystem'"  -PSSession $session | Out-Null
    Invoke-RemoteCommand -Command "[io.compression.zipfile]::ExtractToDirectory('$RemoteFile','$TargetFolder')" -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command "remove-item '$RemoteFile' -Force"  -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command "import-module AdvaniaGIT"  -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command ". C:\AdvaniaGIT\Scripts\CustomActions\Import-NavFob.ps1 -DatabaseName '$($SetupParameters.RemoteDatabaseName)' -DatabaseServer '$($SetupParameters.RemoteDatabaseServerName)' -Path (Get-ChildItem -Path '$($SetupParameters.RemotePath)' -Filter *.fob).FullName -Verbose" -Verbose -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command "remove-item -Path (Get-ChildItem -Path $($SetupParameters.RemotePath) -Filter *.fob).FullName -Force" -CloseSession -PSSession $session| Out-Null
} catch {
    throw $_
}