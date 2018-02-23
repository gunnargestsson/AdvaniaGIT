Function Download-NAVFile
{
    param (
        [String]$Url,
        [String]$FileName
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Try { 
        Invoke-WebRequest -Uri $Url -OutFile $FileName -ErrorAction Stop 
    }
         
    Catch [System.Exception] { 
        $WebReqErr = $error[0] | Select-Object * | Format-List -Force 
        Write-Error "An error occurred while attempting to connect to the requested site.  The error was $WebReqErr.Exception" 
    }    
}