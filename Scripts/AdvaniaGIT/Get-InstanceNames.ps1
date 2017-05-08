function Get-InstanceNames
{
    $instanceNames = @()
    Get-NAVServerInstance | Select-Object -Property ServerInstance | foreach {
        $instanceName = $_.ServerInstance
        $instanceNames += $instanceName.Substring(27,$instanceName.Length - 27)
    }
    Return $instanceNames
}
