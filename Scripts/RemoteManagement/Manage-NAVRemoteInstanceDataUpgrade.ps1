Function Manage-NAVRemoteInstanceDataUpgrade {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance
    )
    Write-Host "Loading Data Upgrade Menu for $($SelectedInstance.ServerInstance) on $($SelectedInstance.HostName):"
    $Session = New-NAVRemoteSession -Credential $Credential -HostName $SelectedInstance.PSComputerName 

    do {
        Clear-Host
        For ($i=0; $i -le 10; $i++) { Write-Host "" }
        $selectedInstance | Format-Table -Property HostName, ServerInstance, DatabaseName, Multitenant, Version, State -AutoSize 
        $input = Read-Host "Please select action:`
    0 = Exit, `
    1 = Start Data Upgrade with Company Initialization, `
    2 = Start Data Upgrade without Company Initialization, `
    3 = Restart Data Upgrade, `
    4 = Stop Data Upgrade, `
    5 = Get Data Upgrade Status, `
    6 = Get Data Upgrade Details, `
    Select action"
        switch ($input) {
            '0' { break }
            '1' { Start-NAVRemoteInstanceDataUpgrade -Session $Session -SelectedInstance $SelectedInstance }
            '2' { Start-NAVRemoteInstanceDataUpgrade -Session $Session -SelectedInstance $SelectedInstance -SkipCompanyInitialization }
            '3' { Resume-NAVRemoteInstanceDataUpgrade -Session $Session -SelectedInstance $SelectedInstance }
            '4' { Stop-NAVRemoteInstanceDataUpgrade -Session $Session -SelectedInstance $SelectedInstance }
            '5' { Get-NAVRemoteInstanceDataUpgrade -Session $Session -SelectedInstance $SelectedInstance }
            '6' { Get-NAVRemoteInstanceDataUpgrade -Session $Session -SelectedInstance $SelectedInstance -Details $true }
        }                    
    }
    until ($input -iin ('0'))    
    Remove-PSSession $Session
}