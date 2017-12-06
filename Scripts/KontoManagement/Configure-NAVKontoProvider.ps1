Function Configure-NAVKontoProvider {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Provider
    )
    do {
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $menuItems = Load-NAVKontoAccountantStartMenu -Provider $Provider -Accountants $Provider.Accountants
        $menuItems | Format-Table -Property No, Name, Status, NoOfUsers, Message -AutoSize 
        $input = Read-Host "Please select accountant number (0 = exit, + = Add new)"
        switch ($input) {
            '0' { break }
            '+' { $Provider = New-NAVKontoAccountant -Provider $Provider }
            default {
                $selectedAccountant = $menuItems | Where-Object -Property No -EQ $input
                if ($selectedAccountant) { 
                    Clear-Host
                    For ($i=0; $i -le 10; $i++) { Write-Host "" }                    
                    $selectedAccountant | Format-Table -Property No, Name, Status, NoOfUsers, Message -AutoSize
                    $instanceConfig = $selectedAccountant | Select-Object -Property PublicODataBaseUrl,PublicSOAPBaseUrl,PublicWebBaseUrl
                    $instanceConfig | Add-Member -MemberType NoteProperty -Name ClickOnceUrl -Value "$($Provider.ClickOnceUrl)/365"
                    $input = Read-Host "Please select action (0 = exit, 1 = set accountant active, 2 = set accountant inactive, 3 = tenants)"
                    switch ($input) {
                        '0' { break }
                        '1' { $response = Post-NAVKontoResponse -Provider $Provider -Query "update-bookkeeper?guid=$($selectedAccountant.guid)&status=Active&count_of_bookkeepers=$($selectedAccountant.NoOfUsers)&instance_config=$([System.Web.HttpUtility]::UrlEncode($(ConvertTo-Json -InputObject $instanceConfig)))" -Content "{}"  }
                        '2' { $response = Post-NAVKontoResponse -Provider $Provider -Query "update-bookkeeper?guid=$($selectedAccountant.guid)&status=Inactive" -Content "{}"  }
                        '3' { Configure-NAVKontoAccountant -Provider $Provider -Accountant $selectedAccountant }
                    }
                }
            }
        }
    }
    until ($input -eq '0')        
}