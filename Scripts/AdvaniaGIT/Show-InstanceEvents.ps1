function Show-InstanceEvents
{
    param (
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$InstanceName
    )
    $ProviderName = (Get-Service | Where-Object -Property Name -Match $InstanceName).Name
    Get-WinEvent -ProviderName $ProviderName -MaxEvents 20 | Format-Table -Property LevelDisplayName, Message -Wrap -AutoSize
}