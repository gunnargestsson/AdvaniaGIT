Function Import-NAVRemoteObjectsToDockerContainer
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [parameter(Mandatory=$true)]
        [String]$DestinationZipFile
    )

    Invoke-Command -Session $Session -ScriptBlock `
    {
        param([String]$DestinationZipFile)
        $DestinationFilePath = Split-Path -Path $DestinationZipFile -Parent
        $DestinationFileName = (Get-Item -Path $DestinationZipFile).BaseName
        Remove-Item -Path (Join-Path $DestinationFilePath $DestinationFileName) -Recurse -Force -ErrorAction SilentlyContinue
        Expand-Archive -Path $DestinationZipFile -DestinationPath $DestinationFilePath -Force

        $Session = New-DockerSession -DockerContainerId $BranchSettings.DockerContainerId
        Invoke-Command -Session $Session -ScriptBlock `
        {
            param([String]$ObjectsFolderPath)           
            $ObjectsPath = Join-Path "C:\GIT" $ObjectsFolderPath
            Import-Module AdvaniaGIT
            $SetupParameters = Get-GITSettings
            Load-ModelTools -SetupParameters $SetupParameters
            $BranchSettings = Get-BranchSettings -SetupParameters $SetupParameters
            Write-Host "Importing files from ${ObjectsPath}..."
            
            $Fobs = Get-Item -Path (Join-path $ObjectsPath "*.FOB")
            if ($Fobs) {
                foreach ($Fob in $Fobs) {
                    Write-Host "Importing $($Fob.FullName)..."
                    Import-NAVApplicationGITObject -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Path $Fob.FullName -ImportAction Overwrite -SynchronizeSchemaChanges Force
                }
            }

            Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath (Join-path $ObjectsPath "*.TXT")
            Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings -Wait
            UnLoad-ModelTools 
        } -ArgumentList $DestinationFileName
        Remove-PSSession $Session
    } -ArgumentList $DestinationZipFile
}