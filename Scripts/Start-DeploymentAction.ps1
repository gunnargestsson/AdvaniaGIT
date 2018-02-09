param
(
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
[String]$Repository = (Get-Location).Path,
[Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[String]$ScriptName,
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[HashTable]$BuildSettings,
[Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
[HashTable]$DeploymentSettings
)
    # Import all needed modules
    Import-Module AdvaniaGIT -DisableNameChecking | Out-Null
    Import-Module RemoteManagement -DisableNameChecking | Out-Null

    Push-Location 
    Set-Location $Repository
    
    # Get Environment Settings
    $SetupParameters = Get-GITSettings
           
    # Set Global Parameters
    $Globals = New-Object -TypeName PSObject
    $Globals | Add-Member WorkFolder $Repository
    $Globals | Add-Member LogPath  (Join-Path $SetupParameters.rootPath "Log\$([GUID]::NewGuid().GUID)")

    $SetupParameters = Combine-Settings $Globals $SetupParameters
    if (![String]::IsNullOrEmpty($BuildSettings)) { $SetupParameters = Combine-Settings (New-Object -TypeName PSObject -Property $BuildSettings) $SetupParameters }

    New-Item -Path (Split-Path -Path $SetupParameters.LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path $SetupParameters.LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ($IsInAdminMode ) { Add-BlankLines -SetupParameters $SetupParameters }
    $env:WorkFolder = $SetupParameters.WorkFolder
    
    # Start the script
    $ScriptToStart = (Join-Path (Join-path $PSScriptRoot 'DeploymentActions') $ScriptName)
    & $ScriptToStart
    Pop-Location

