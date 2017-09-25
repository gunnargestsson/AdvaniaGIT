Function Get-NAVSelectedInstances
{
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$ServerInstances
        )
  
    $instanceNo = 1
    $menuItems = @()
    Write-Host "Loading Remote Instance Menu..."
    if ($ServerInstances.Length -eq $null) { return $ServerInstances }
    foreach ($instance in $ServerInstances) {
        if (!($instance | Get-Member | Where-Object -Property Name -EQ No)) {
            $instance | Add-Member -MemberType NoteProperty -Name No -Value $instanceNo
            $instanceNo ++
        }
        $menuItems += $instance
    }            
  
    $menuItems | Format-Table -Property No, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize | Out-Host

    $input = Read-Host "Please select instance number (0 = exit, + = all)"
    switch ($input) {
        '0' { return $null }
        '+' { return $ServerInstances }
        default { return $menuItems | Where-Object -Property No -EQ $input }
    }                    
}