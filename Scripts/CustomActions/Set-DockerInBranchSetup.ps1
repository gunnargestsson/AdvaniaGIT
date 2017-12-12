$SetupJson = Get-Content $SetupParameters.setupPath -Encoding UTF8 | Out-String | ConvertFrom-Json
if ($($SetupJson.navSolution.SubString(0,2)) -eq "W1") {
    $SetupJson | Add-Member -MemberType NoteProperty -Name dockerImage -Value "microsoft/dynamics-nav:$($SetupJson.navBuild)" -Force
} else {
    $SetupJson | Add-Member -MemberType NoteProperty -Name dockerImage -Value "microsoft/dynamics-nav:$($SetupJson.navBuild)-$($SetupJson.navSolution.SubString(0,2).ToLower())" -Force
}


Set-Content -Value ($SetupJson | ConvertTo-Json) -Encoding UTF8 -Path $SetupParameters.setupPath