function Enable-TcpPortSharingForNAVService
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string]$Computer="localhost"

    )
    $Service = $BranchSettings.instanceName
    if (!$Service.Contains('MicrosoftDynamicsNavServer$')) {
        $Service = 'MicrosoftDynamicsNavServer$' + $Service
    }
    Write-Host "Setting service $Service to use port sharing"        
    $command = 'sc.exe \\$Computer config "$Service" depend= NetTcpPortSharing/HTTP'
    $Output = Invoke-Expression -Command $Command -ErrorAction Stop
    if($LASTEXITCODE -ne 0){
        Write-Error "$Computer : Failed to set $Service TcpPortSharing.  More details: $Output" -foregroundcolor red 
        }

}