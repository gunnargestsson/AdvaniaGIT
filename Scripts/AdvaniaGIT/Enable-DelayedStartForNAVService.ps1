function Enable-DelayedStartForNAVService
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
    Write-Host "Setting service $Service to delayed start"        
    $command = 'sc.exe \\$Computer config "$Service" start= delayed-auto'
    $Output = Invoke-Expression -Command $Command -ErrorAction Stop
    if($LASTEXITCODE -ne 0){
        Write-Error "$Computer : Failed to set $Service to delayed start.  More details: $Output" 
        }
}