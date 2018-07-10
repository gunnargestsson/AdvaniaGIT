Function Download-NAVFile
{
    param (
        [String]$Url,
        [String]$FileName
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $pp = $ProgressPreference
    Try { 
        $ProgressPreference = 'SilentlyContinue'
        Invoke-RestMethod -ContentType "application/octet-stream" -Uri $Url -OutFile $FileName -ErrorAction Stop 
    }
         
    Catch [System.Exception] { 
        $WebReqErr = $error[0] | Select-Object * | Format-List -Force 
        Write-Error "An error occurred while attempting to connect to the requested site.  The error was $WebReqErr.Exception" 
    }
        
    finally {
            $ProgressPreference = $pp
    }
}