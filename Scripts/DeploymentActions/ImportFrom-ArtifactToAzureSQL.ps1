Import-Module RemoteManagement -DisableNameChecking | Out-Null
$DbAdmin = Get-NAVPasswordStateUser -PasswordId $SetupParameters.SqlServerPid
$VMAdmin = Get-NAVPasswordStateUser -PasswordId $SetupParameters.NavServerPid
$VMCredential = New-Object System.Management.Automation.PSCredential($VMAdmin.UserName, (ConvertTo-SecureString $VMAdmin.Password -AsPlainText -Force))

$WorkFolder = 'c:\AdvaniaGIT\Workspace'
$Session = New-NAVRemoteSession -Credential $VMCredential -HostName $SetupParameters.NavServerHostName -SetupPath $WorkFolder
$ObjectsFiles = Get-ChildItem -Path $SetupParameters.workFolder -Filter *.fob
foreach ($ObjectsFile in $ObjectsFiles) {
    Write-Host "Uploading Artifact to remote server..."
    Compress-Archive -Path $ObjectsFile.FullName -DestinationPath (Join-Path $WorkFolder 'Objects.zip') -Force
    Copy-FileToRemoteMachine -Session $Session -SourceFile (Join-Path $WorkFolder 'Objects.zip') -DestinationFile (Join-Path $WorkFolder 'Objects.zip') 
    Remove-Item -Path (Join-Path $WorkFolder 'Objects.zip')  -Force -ErrorAction SilentlyContinue
}

# SqlServerDb='2016-ADIS'
