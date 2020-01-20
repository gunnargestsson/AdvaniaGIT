# https://github.com/kine/NVRAppDevOps/blob/master/Get-ALAppOrder.ps1
function Get-ALBuildOrder
{
    Param(
        $Apps
    )
    $AppsOrdered = @()
    $AppsToAdd = @{}
    $AppsCompiled = @{}
    do {
        foreach($App in $Apps.GetEnumerator()) {
            if (-not $AppsCompiled.ContainsKey($App.Value.name)) {
                #test if all dependencies are compiled
                $DependencyOk = $true
                foreach ($Dependency in $App.Value.dependencies) {
                    if (-not $Apps.Contains($Dependency.name)) {
                        $NewApp=New-Object -TypeName PSObject
                        $NewApp | Add-Member -MemberType NoteProperty -Name 'name' -Value $Dependency.name
                        $NewApp | Add-Member -MemberType NoteProperty -Name 'version' -Value $Dependency.version
                        $NewApp | Add-Member -MemberType NoteProperty -Name 'publisher' -Value $Dependency.publisher
                        $NewApp | Add-Member -MemberType NoteProperty -Name 'AppPath' -Value ""

                        if (-not $AppsCompiled.ContainsKey($Dependency.name)) {
                            $AppsCompiled.Add($Dependency.name,$NewApp)
                            $AppsToAdd.Add($Dependency.name,$NewApp)
                            $AppsOrdered += $NewApp
                        }
                    }
                    if (-not $AppsCompiled.ContainsKey($Dependency.name)) {
                        $DependencyOk = $false
                    }
                }
                if ($DependencyOk) {
                    $AppsOrdered += $App.Value
                    $AppsCompiled.Add($App.Value.name,$App.Value)
                }
            }
        }
        foreach ($App in $AppsToAdd.GetEnumerator()) {
            $Apps.Add($App.Value.name,$App.Value)
        }
        $AppsToAdd =@{}
    } while ($Apps.Count -ne $AppsCompiled.Count)
    return $AppsOrdered
}