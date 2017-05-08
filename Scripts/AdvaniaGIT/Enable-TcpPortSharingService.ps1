function Enable-TcpPortSharingService
{
    param (
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [string]$Computer="localhost"
    )

    #Set Startup Mode for NetTcpPortSharing to Manual
    $command = 'sc.exe \\$Computer config "NetTcpPortSharing" start= demand'
    $Output = Invoke-Expression -Command $Command -ErrorAction Stop
    if($LASTEXITCODE -ne 0){
        Write-Error "$Computer : Failed to set NetTcpPortSharing to manual start.  More details: $Output" 
        }
}