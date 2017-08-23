function Get-DockerContainers
{    
    $result = @()
    $result += (docker.exe ps --all --format "{{.ID}},{{.Image}},{{.Status}}")
    if ($result.Length -gt 0) {
        $dockerContainers = @()
        for ($i=0; $i -lt $result.Length; $i++) {
            $parts = $result[$i].Split(",")
            $dockerContainer = New-Object -TypeName PSObject
            $dockerContainer | Add-Member -MemberType NoteProperty -Name Id -Value $parts[0]
            $dockerContainer | Add-Member -MemberType NoteProperty -Name Image -Value $parts[1]
            $dockerContainer | Add-Member -MemberType NoteProperty -Name Status -Value $parts[2]
            $dockerContainers += $dockerContainer
        }
        return $dockerContainers
    }
}
