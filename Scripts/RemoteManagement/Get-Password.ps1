Function Get-Password {
    param(
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [String]$Message,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$AsSecureString
    )
    PROCESS
    {
        
        $response = Read-host $Message -AsSecureString
        if ($AsSecureString) {
            Return $response
        } else {
            Return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response))
        }
    }
}