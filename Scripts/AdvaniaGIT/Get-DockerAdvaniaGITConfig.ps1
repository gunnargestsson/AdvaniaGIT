Function Get-DockerAdvaniaGITConfig {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$ContainerName
    )

    $DockerSettings = Invoke-ScriptInNavContainer -containerName $ContainerName -ScriptBlock { 
        param([PSObject]$SetupParameters, [PSObject]$BranchSettings, [String]$GeoId, [String]$LocaleName )
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted 
        Import-Module AdvaniaGIT
        $GITSettings = Get-GITSettings
        $BranchSettings = Get-BranchSettings -SetupParameters $GITSettings
        $DockerSettings = New-Object -TypeName PSObject
        $DockerSettings | Add-Member -MemberType NoteProperty -Name GITSettings -Value $GITSettings
        $DockerSettings | Add-Member -MemberType NoteProperty -Name BranchSettings -Value $BranchSettings
        Return $DockerSettings
    } -ArgumentList ($SetupParameters, $BranchSettings, (Get-WinHomeLocation).GeoId, (Get-WinSystemLocale).Name)
    Return $DockerSettings
}