Function Start-NAVRemoteWebClient {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$SelectedInstance,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$TenantId="default"
    )
    Start-Process ($SelectedInstance.PublicWebBaseUrl + "?tenant=$TenantId")
}