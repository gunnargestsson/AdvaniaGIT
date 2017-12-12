function Decrypt-Rijndael256ECB {
    param(
        [byte[]]$Key,
        [string]$CipherText
    )

    $RijndaelProvider = New-Object -TypeName System.Security.Cryptography.RijndaelManaged

    $RijndaelProvider.BlockSize = 256
    $RijndaelProvider.Mode      = [System.Security.Cryptography.CipherMode]::ECB
    $RijndaelProvider.Key       = $key
    $RijndaelProvider.Padding   = [System.Security.Cryptography.PaddingMode]::None

    $Decryptor = $RijndaelProvider.CreateDecryptor()

    # Reverse process: Base64Decode first, then populate memory stream with ciphertext and lastly read decrypted data through cryptostream
    $Cipher = [convert]::FromBase64String($CipherText) -as [byte[]]

    $DecMemoryStream = New-Object System.IO.MemoryStream -ArgumentList @(,$Cipher)
    $DecCryptoStream = New-Object System.Security.Cryptography.CryptoStream -ArgumentList $DecMemoryStream,$Decryptor,$([System.Security.Cryptography.CryptoStreamMode]::Read)
    $DecStreamWriter = New-Object System.IO.StreamReader -ArgumentList $DecCryptoStream

    $NewPlainText = $DecStreamWriter.ReadToEnd()

    $DecStreamWriter.Close()
    $DecCryptoStream.Close()
    $DecMemoryStream.Close()

    return $NewPlainText
}
