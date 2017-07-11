Function New-NAVRemoteSession {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$HostName,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$SetupPath
    )

    if (!($SetupPath)) {
        $SetupPath = Join-path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "Data"
    }
    $WinRmUri = New-Object Uri("https://$($HostName):5986")    
    $WinRmOption = New-PSSessionOption –SkipCACheck –SkipCNCheck –SkipRevocationCheck
    $Session = New-PSSession -ConnectionUri $WinRMUri -Credential $Credential -SessionOption $WinRmOption
    Invoke-Command -Session $Session -ScriptBlock `
        {
            param([string] $SetupPath)
            Import-Module AdvaniaGIT -DisableNameChecking | Out-Null 
            if (!(Test-Path -Path $SetupPath)) {
                $SetupPath = Join-Path $env:SystemDrive "AdvaniaGIT\Data"
            }
            $SetupParameters = Get-GITSettings            
            $SetupParameters | Add-Member "Repository" $SetupPath
            $SetupParameters | Add-Member "Branchname" ""
    
            # Find NAV major version based on the repository NAV version - client
            $mainVersion =  ($SetupParameters.navVersion).Split('.').GetValue(0) + ($SetupParameters.navVersion).Split('.').GetValue(1)
            $SetupParameters | Add-Member "mainVersion" $mainVersion
            $SetupParameters | Add-Member "navIdePath" (Get-NAVClientPath -SetupParameters $SetupParameters)
            $SetupParameters | Add-Member "navServicePath" (Get-NAVServicePath -SetupParameters $SetupParameters)
    
            # Find NAV Release
            $SetupParameters | Add-Member "navRelease" (Get-NAVRelease -mainVersion $mainVersion)
   
            # Set Global Parameters
            $Globals = New-Object -TypeName PSObject
            $Globals | Add-Member WorkFolder $SetupParameters.workFolder
            $Globals | Add-Member BackupPath  (Join-Path $SetupParameters.rootPath "Backup")
            $Globals | Add-Member DatabasePath  (Join-Path $SetupParameters.rootPath "Database")
            $Globals | Add-Member SourcePath  (Join-Path $SetupParameters.rootPath "Source")
            $Globals | Add-Member ExecutingBuild $false
            $Globals | Add-Member SetupPath  (Join-Path $SetupPath $SetupParameters.setupPath)
            $Globals | Add-Member ObjectsPath  (Join-Path $SetupPath $SetupParameters.objectsPath)
            $Globals | Add-Member DeltasPath  (Join-Path $SetupPath $SetupParameters.deltasPath)
            $Globals | Add-Member ReverseDeltasPath  (Join-Path $SetupPath $SetupParameters.reverseDeltasPath)
            $Globals | Add-Member ExtensionPath  (Join-Path $SetupPath $SetupParameters.extensionPath)
            $Globals | Add-Member ImagesPath  (Join-Path $SetupPath $SetupParameters.imagesPath)
            $Globals | Add-Member ScreenshotsPath  (Join-Path $SetupPath $SetupParameters.screenshotsPath)
            $Globals | Add-Member PermissionSetsPath  (Join-Path $SetupPath $SetupParameters.permissionSetsPath)
            $Globals | Add-Member AddinsPath  (Join-Path $SetupPath $SetupParameters.addinsPath)
            $Globals | Add-Member LanguagePath  (Join-Path $SetupPath $SetupParameters.languagePath)
            $Globals | Add-Member TableDataPath  (Join-Path $SetupPath $SetupParameters.tableDataPath)
            $Globals | Add-Member CustomReportLayoutsPath  (Join-Path $SetupPath $SetupParameters.customReportLayoutsPath)
            $Globals | Add-Member WebServicesPath  (Join-Path $SetupPath $SetupParameters.webServicesPath)
            $Globals | Add-Member BinaryPath  (Join-Path $SetupPath $SetupParameters.binaryPath)
            $Globals | Add-Member LogPath  (Join-Path $SetupParameters.rootPath "Log\$([GUID]::NewGuid().GUID)")
            $Globals | Add-Member LicensePath  (Join-Path $SetupParameters.rootPath "License")
            $Globals | Add-Member LicenseFilePath (Join-Path $Globals.LicensePath $SetupParameters.licenseFile)
            $Globals | Add-Member DownloadPath  (Join-Path $SetupParameters.rootPath "Download")
            $SetupParameters = Combine-Settings $Globals $SetupParameters

            New-Item -Path (Split-Path -Path $SetupParameters.LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            New-Item -Path $SetupParameters.LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
            if (Test-Path (Join-Path (Split-Path $SetupPath -Parent) "mage.exe")) {
                $SetupParameters | Add-Member MageExeLocation (Join-Path (Split-Path $SetupPath -Parent) "mage.exe")
            }
        } -ArgumentList $SetupPath
        
    Return $Session
}