function Start-AdvaniaGITAction {
    param
    (
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
    [String]$Repository = (Get-Location).Path,
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
    [String]$ScriptName,
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
    [String]$InAdminMode='$false',
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
    [String]$Wait='$false',
    [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true)]
    [HashTable]$BuildSettings
    )
    $SetupParameters = Get-GITSettings
    $CustomActionPath = Join-Path $SetupParameters.rootPath 'Scripts\Start-CustomAction.ps1'
    & $CustomActionPath -Repository $Repository -ScriptName $ScriptName -InAdminMode $InAdminMode -Wait $Wait -BuildSettings $BuildSettings
}
