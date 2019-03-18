$SetupJson = Get-Content $SetupParameters.setupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
if ([String]::IsNullOrEmpty($SetupParameters.CUBuildMode) -or $SetupParameters.CUBuildMode -eq $false) {
    if ([int]$SetupParameters.navVersion.Split(".")[0] -ge 13) {
        if ($($SetupJson.navSolution.SubString(0,2)) -eq "W1") {
            $SetupJson | Add-Member -MemberType NoteProperty -Name dockerImage -Value "mcr.microsoft.com/businesscentral/onprem" -Force
        } else {
            $SetupJson | Add-Member -MemberType NoteProperty -Name dockerImage -Value "mcr.microsoft.com/businesscentral/onprem:$($SetupJson.navSolution.SubString(0,2).ToLower())" -Force
        }
 
    } else  {
        if ($($SetupJson.navSolution.SubString(0,2)) -eq "W1") {
            $SetupJson | Add-Member -MemberType NoteProperty -Name dockerImage -Value "mcr.microsoft.com/dynamics-nav:$(($SetupJson.navBuild).substring(0,4))" -Force
        } else {
            $SetupJson | Add-Member -MemberType NoteProperty -Name dockerImage -Value "mcr.microsoft.com/dynamics-nav:$(($SetupJson.navBuild).substring(0,4))-$($SetupJson.navSolution.SubString(0,2).ToLower())" -Force
        }
    }
}

if ($SetupParameters.BuildMode) {
    $SetupJson | Add-Member -MemberType NoteProperty -Name branchId -Value (New-Guid) -Force
    $SetupJson | Add-Member -MemberType NoteProperty -Name dockerFriendlyName -Value "$(Split-Path $SetupParameters.Repository -Leaf)               ".Substring(0,15).TrimEnd(" ") -Force
}

Set-Content -Value ($SetupJson | ConvertTo-Json) -Encoding UTF8 -Path $SetupParameters.setupPath
if ($SetupParameters.BuildMode) {
    $SetupJson | Add-Member -MemberType NoteProperty -Name branchId -Value (New-Guid) -Force
    $SetupJson | Add-Member -MemberType NoteProperty -Name dockerFriendlyName -Value "$(Split-Path $SetupParameters.Repository -Leaf)               ".Substring(0,15).TrimEnd(" ") -Force
}

Set-Content -Value ($SetupJson | ConvertTo-Json) -Encoding UTF8 -Path $SetupParameters.setupPath