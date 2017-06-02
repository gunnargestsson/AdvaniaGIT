
Get-Module -Name AdvaniaGIT | Remove-Module
Import-Module AdvaniaGIT
try {
    $RemoteFile = 'C:\AdvaniaGIT\Workspace\archive.zip'
    $LocalArchive = Join-Path $env:Temp 'archive.zip'
    $TargetFolder = 'c:\AdvaniaGIT\Workspace'
    Add-Type -assembly 'system.io.compression.filesystem'

    Remove-Item $LocalArchive -Force -ErrorAction SilentlyContinue| Out-Null
    Write-Verbose 'Compressing the file'
    [io.compression.zipfile]::CreateFromDirectory($env:bamboo_working_directory,$LocalArchive)

    $session = Invoke-RemoteCommand -Command 'import-module "C:\Program Files\Microsoft Dynamics NAV\100\Service\Microsoft.Dynamics.Nav.Management.dll"' -Verbose 
    Write-Verbose 'Copying file to remote machine'
    Invoke-RemoteCommand -Command "remove-item '$RemoteFile' -Force -ErrorAction SilentlyContinue" -Verbose -PSSession $session | Out-Null
    Copy-FileToRemoteMachine -SourceFile $LocalArchive -DestinationFile $RemoteFile -Session $session | Out-Null
    Remove-Item -Path $LocalArchive -Force | Out-Null
    Write-Verbose 'Copying finished'
    Invoke-RemoteCommand -Command 'Add-Type -assembly "system.io.compression.filesystem"' -Verbose -PSSession $session | Out-Null
    Invoke-RemoteCommand -Command "[io.compression.zipfile]::ExtractToDirectory('$RemoteFile','$TargetFolder')" -Verbose -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command "remove-item '$RemoteFile' -Force" -Verbose -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command 'import-module AdvaniaGIT' -Verbose -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command ". C:\AdvaniaGIT\Scripts\CustomActions\Import-NavFob.ps1 -DatabaseName '$($env:bamboo_AzureDB_DatabaseName)' -DatabaseServer '$($env:bamboo_AzureDB_ServerName)' -Path (Get-ChildItem -Path $RemoteFolder -Filter *.fob).FullName -Verbose" -Verbose -PSSession $session| Out-Null
    Invoke-RemoteCommand -Command 'remove-item -Path (Get-ChildItem -Path $RemoteFolder -Filter *.fob).FullName -Force' -Verbose -CloseSession -PSSession $session| Out-Null
} catch {
    throw $_
}