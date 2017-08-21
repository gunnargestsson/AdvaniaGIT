function Get-RunningDockerHosts
{    
    $result = @()
    $result += (docker ps)
    if ($result.Length -gt 1) {
        $dockerHosts = @()
        $result = $result[1..$result.Length]    
        for ($i=0; $i -lt $result.Length; $i++) {
            $result[$i] | foreach {$parts = $_ -split "\s+", 6}
            $dockerHost = New-Object -TypeName PSObject
            $dockerHost | Add-Member -MemberType NoteProperty -Name ContainerId -Value $parts[0]
            $dockerHost | Add-Member -MemberType NoteProperty -Name Image -Value $parts[1]
            $dockerHosts += $dockerHost
        }
        return $dockerHosts
    }
}
