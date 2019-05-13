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

        Invoke-ScriptInNavContainer -containerName $BranchSettings.dockerContainerName -ScriptBlock `
        {
            param([String]$ObjectsFolderPath)           
            $ObjectsPath = Join-Path "C:\GIT" $ObjectsFolderPath
            Import-Module AdvaniaGIT | Out-Null
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

            Update-NAVApplicationFromTxt -SetupParameters $SetupParameters -BranchSettings $BranchSettings -ObjectsPath (Join-path $ObjectsPath "*.TXT") -SkipDeleteCheck
            Compile-UncompiledObjects -SetupParameters $SetupParameters -BranchSettings $BranchSettings
            UnLoad-ModelTools 
        } -ArgumentList $DestinationFileName
    } -ArgumentList $DestinationZipFile
}