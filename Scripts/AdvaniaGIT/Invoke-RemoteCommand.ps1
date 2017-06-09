Function Invoke-RemoteCommand
{
    [CmdletBinding()]
    param(
        $VMAdminUserName,
        $VMAdminPassword,
        $VMURL,
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        $PSSession,
        $Command,
        [Switch]$CloseSession
    )

    if ($env:bamboo_AzureVM_ServerName -and (-not $PSSession)) {
        Write-Host 'Taking parameters from bamboo'
        $VMAdminUserName = $env:bamboo_AzureVM_Username
        $VMAdminPassword = $env:bamboo_AzureVM_Password
        $VMURL = $env:bamboo_AzureVM_ServerName
    }
    if (-not $PSSession) {
        Write-Verbose 'Creating session to remote computer'
        $WinRmUri = New-Object Uri("https://$($VMURL):5986") -ErrorAction Stop
        $WinRmCredential = New-Object System.Management.Automation.PSCredential($VMAdminUserName, (ConvertTo-SecureString $VMAdminPassword -AsPlainText -Force))
        $WinRmOption = New-PSSessionOption –SkipCACheck –SkipCNCheck –SkipRevocationCheck
        $PSSession = New-PSSession -ConnectionUri $WinRMUri -Credential $WinRmCredential -SessionOption $WinRmOption
        Write-Verbose 'Copying env: variables to remote (only adding new)'
        Copy-EnvVariableToRemote -Session $PSSession -Variables (Get-ChildItem env:)
    }
    $scriptblock = [ScriptBlock]::Create($Command)
    Write-Verbose "Executing $Command on remote machine"
    Invoke-Command -Session $PSSession -ScriptBlock $scriptblock -ErrorAction Stop

    if ($CloseSession) {
        $PSSession | Remove-PSSession
    } else {
        Write-Output $PSSession
    }
}