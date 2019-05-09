foreach ($Container in Get-DockerContainers) {
  Write-Host "Container: $($Container.Names), status: $($Container.Status) found"  
  if ($Container.Status -notmatch "Exited") {
    Write-Host "Stopping..."
    docker kill $Container.Id
  }
}
