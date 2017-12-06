function Encrypt-Rijndael256ECB {
    param(
        [byte[]]$Key,
        [string]$Plaintext
    )

    $RijndaelProvider = New-Object -TypeName System.Security.Cryptography.RijndaelManaged

    # Set block size to 256 to imitate MCRYPT_RIJNDAEL_256
    $RijndaelProvider.BlockSize = 256
    # Make sure we use ECB mode, or the generated IV will fuck up the first block upon decryption
    $RijndaelProvider.Mode      = [System.Security.Cryptography.CipherMode]::ECB
    $RijndaelProvider.Key       = $key

    # This object will take care of the actual cryptographic transformation
    $Encryptor = $RijndaelProvider.CreateEncryptor()

    # Set up a memorystream that we can write encrypted data back to
    $EncMemoryStream = New-Object System.IO.MemoryStream
    $EncCryptoStream = New-Object System.Security.Cryptography.CryptoStream -ArgumentList $EncMemoryStream,$Encryptor,"Write"
    $EncStreamWriter = New-Object System.IO.StreamWriter -ArgumentList $EncCryptoStream

    # When we write data back to the CryptoStream, it'll get encrypted and written back to the MemoryStream
    $EncStreamWriter.Write($Plaintext)

    # Close the writer
    $EncStreamWriter.Close()
    # Close the CryptoStream (pads and flushes any data still left in the buffer)
    $EncCryptoStream.Close()
    $EncMemoryStream.Close()

    # Read the encrypted message from the memory stream
    $Cipher     = $EncMemoryStream.ToArray() -as [byte[]]
    $CipherText = [convert]::ToBase64String($Cipher)

    # return base64 encoded encrypted string
    return $CipherText
}