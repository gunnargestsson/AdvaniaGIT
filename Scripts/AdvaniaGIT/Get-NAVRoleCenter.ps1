Function Get-NAVRoleCenter {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SetupParameters,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$BranchSettings
    )
    
    $profileNo = 1
    $Profiles = @()
    $command = "SELECT [Profile ID],[Description],[Role Center ID],[Default Role Center] FROM [dbo].[Profile]"
    $results = Get-SQLCommandResult -Server (Get-DatabaseServer -BranchSettings $BranchSettings) -Database $BranchSettings.databaseName -Command $Command -Username $SetupParameters.SqlUsername -Password $SetupParameters.SqlPassword


    foreach ($result in $results) {
        $profile = New-Object -TypeName PSObject               
        $profile | Add-Member -MemberType NoteProperty -Name No -Value $profileNo
        $profile | Add-Member -MemberType NoteProperty -Name Id -Value $result.'Profile ID'
        $profile | Add-Member -MemberType NoteProperty -Name Description -Value $result.Description
        $profile | Add-Member -MemberType NoteProperty -Name PageID -Value $result.'Role Center ID' 
        $profile | Add-Member -MemberType NoteProperty -Name Default -Value ($result.'Default Role Center' -eq 1)
        $profileNo ++
        $Profiles += $profile
        }
 
    do {
        # Start Menu
        Clear-Host
        $Profiles | Format-Table -Property No, Id, Description, PageID, Default -AutoSize | Out-Host
        $input = Read-Host "Please select startup rolecenter (<Enter> for default)"
        switch ($input) {
            '' { 
                $selectedProfile = $Profiles | Where-Object -Property Default -EQ $true
                if ($selectedProfile) { return $selectedProfile.Id }
            }
            default {
                $selectedProfile = $Profiles | Where-Object -Property No -EQ $input
                if ($selectedProfile) { return $selectedProfile.Id }
            }
        }
    }
    until ($input -ieq '')   
    
}