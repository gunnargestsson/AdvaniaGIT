function Start-DockerRun {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$imageName,
        [switch]$accept_eula,
        [switch]$accept_outdated,
        [switch]$wait,
        [string[]]$parameters
    )

    if ($accept_eula) {
        $parameters += "--env accept_eula=Y"
    }
    if ($accept_outdated) {
        $parameters += "--env accept_outdated=Y"
    }
    if (!$wait) {
        $parameters += "--detach"
    }
    $parameters += $imageName

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "docker.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = ("run "+[string]::Join(" ", $parameters))
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $output = $p.StandardOutput.ReadToEnd()
    $output += $p.StandardError.ReadToEnd()
    $output.Trim()
}