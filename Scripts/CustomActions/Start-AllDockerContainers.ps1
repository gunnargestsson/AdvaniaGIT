foreach ($Container in Get-DockerContainers) {
  Write-Host "Container: $($Container.Names), status: $($Container.Status) found"
  $DockerConfig = Get-DockerContainerConfiguration -DockerContainerName $Container.Names
  if ($Container.Status -match "Exited") {    
    $DockerSettings = New-Object -TypeName PSObject
    $DockerSettings | Add-Member -MemberType NoteProperty -Name dockerContainerName -Value $Container.Names
    $DockerSettings | Add-Member -MemberType NoteProperty -Name dockerContainerId -Value $DockerConfig.Id
    ReStart-DockerContainer -BranchSettings $DockerSettings
  }
}