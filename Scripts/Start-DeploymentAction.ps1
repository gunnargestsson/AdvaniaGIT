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
    $SetupParameters | Add-Member -MemberType NoteProperty -Name DeploymentMode -Value $true -Force
           
    # Set Global Parameters
    $Globals = New-Object -TypeName PSObject
    $Globals | Add-Member WorkFolder $Repository
    $Globals | Add-Member LogPath  (Join-Path $SetupParameters.rootPath "Log\$([GUID]::NewGuid().GUID)")

    $SetupParameters = Combine-Settings $Globals $SetupParameters
    if (![String]::IsNullOrEmpty($BuildSettings)) { $SetupParameters = Combine-Settings (New-Object -TypeName PSObject -Property $BuildSettings) $SetupParameters }

    if (-not (Test-Path -Path (Split-Path -Path $SetupParameters.LogPath -Parent))) {
        New-Item -Path (Split-Path -Path $SetupParameters.LogPath -Parent) -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    }
    if (-not (Test-Path -Path $SetupParameters.LogPath)) {
        New-Item -Path $SetupParameters.LogPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    }
    $env:WorkFolder = $SetupParameters.WorkFolder
    
    $Error.Clear()

    #Start the script
    Write-Verbose "Starting ${ScriptName}..."
    $ScriptToStart = (Join-Path (Join-path $PSScriptRoot 'DeploymentActions') $ScriptName)            
    & $ScriptToStart
    Write-Verbose "Execution of ${ScriptName} completed"
    Pop-Location   

    if ($Error.Count -gt 0) {
        Write-Verbose "Errors: ${Error}"        
        exit 1
    }

    
  