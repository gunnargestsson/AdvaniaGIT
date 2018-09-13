Function New-NAVAuthenticationDialog {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Usage
    )
    PROCESS
    {

        $credPath = Join-Path $env:LOCALAPPDATA "AdvaniaGIT"
        New-Item -Path $credPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
        $config = 
        $credFileName = "${Usage}-$((Get-Item -Path $Global:SettingsFilePath).Name)"
        if (Test-Path (Join-Path $credPath $credFileName)) {
            $cred = Get-Content -Encoding UTF8 -Path (Join-Path $credPath $credFileName) | ConvertFrom-Json
            $cred.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($($cred.Password | ConvertTo-SecureString)))
        } else {
            switch ($Usage) {
                "VMUserPasswordID" {$Description = "Virtual Machine Remote Powershell Access"}
                "DBUserPasswordID" {$Description = "Service User for SQL Database, include database server in Host Name"}
                "AzureRMUserPasswordID" {$Description = "Azure Portal Access"}
                "EncryptionKeyPasswordID" {$Description = "SQL Database Connection Encryption password"}
                "DatabaseTemplateStoragePasswordID" {$Description = "Access Key for access to tenant template database"}
                "DBAdminPasswordID" {$Description = "System Administrator access for SQL Server, include database server in Host Name"}
            }
            $cred = New-Object -TypeName PSObject
            $cred | Add-Member -MemberType NoteProperty -Name Title -Value $Usage
            $cred | Add-Member -MemberType NoteProperty -Name UserName -Value ""
            $cred | Add-Member -MemberType NoteProperty -Name Description -Value $Description
            $cred | Add-Member -MemberType NoteProperty -Name GenericField1 -Value ""
            $cred | Add-Member -MemberType NoteProperty -Name Password -Value ""
                   
            $Title = $cred.Title
            $UserName = $cred.UserName
            $Description = $cred.Description
            $GenericField1 = $cred.GenericField1
            $Password = $cred.Password

            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

            $Script:OkPressed = 'NO'                        
            $objForm = New-Object System.Windows.Forms.Form 
            $objForm.Text = $Message
            $objForm.Size = New-Object System.Drawing.Size(300,550) 
            $objForm.StartPosition = "CenterScreen"

            $OKButton = New-Object System.Windows.Forms.Button
            $OKButton.Location = New-Object System.Drawing.Size(75,480)
            $OKButton.Size = New-Object System.Drawing.Size(75,23)
            $OKButton.Text = "OK"
            $OKButton.Add_Click({
                $Script:OkPressed=$OKButton.Text;
                $Script:Title=$objTitleTextBox.Text;
                $Script:UserName=$objUserNameTextBox.Text;
                $Script:Description=$objDescriptionTextBox.Text;
                $Script:GenericField1=$objGenericField1TextBox.Text;
                $Script:Password=$objPasswordTextBox.Text;
                $objForm.Close()})
            $objForm.Controls.Add($OKButton)

            $CancelButton = New-Object System.Windows.Forms.Button
            $CancelButton.Location = New-Object System.Drawing.Size(150,480)
            $CancelButton.Size = New-Object System.Drawing.Size(75,23)
            $CancelButton.Text = "Cancel"
            $CancelButton.Add_Click({$objForm.Close()})
            $objForm.Controls.Add($CancelButton)

            $objTitleLabel = New-Object System.Windows.Forms.Label
            $objTitleLabel.Location = New-Object System.Drawing.Size(10,20) 
            $objTitleLabel.Size = New-Object System.Drawing.Size(280,20) 
            $objTitleLabel.Text = "Credential Usage"
         
            $objForm.Controls.Add($objTitleLabel) 

            $objTitleTextBox = New-Object System.Windows.Forms.TextBox 
            $objTitleTextBox.Location = New-Object System.Drawing.Size(10,40) 
            $objTitleTextBox.Size = New-Object System.Drawing.Size(260,20) 
            $objTitleTextBox.Text = $cred.Title
            $objTitleTextBox.Enabled = $false 
            $objForm.Controls.Add($objTitleTextBox)
        
            $objUserNameLabel = New-Object System.Windows.Forms.Label
            $objUserNameLabel.Location = New-Object System.Drawing.Size(10,70) 
            $objUserNameLabel.Size = New-Object System.Drawing.Size(280,20) 
            $objUserNameLabel.Text = "User Name:"
            $objForm.Controls.Add($objUserNameLabel) 

            $objUserNameTextBox = New-Object System.Windows.Forms.TextBox 
            $objUserNameTextBox.Location = New-Object System.Drawing.Size(10,90) 
            $objUserNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
            $objUserNameTextBox.Text = $cred.UserName
            $objForm.Controls.Add($objUserNameTextBox)  

            $objPasswordLabel = New-Object System.Windows.Forms.Label
            $objPasswordLabel.Location = New-Object System.Drawing.Size(10,220) 
            $objPasswordLabel.Size = New-Object System.Drawing.Size(280,20) 
            $objPasswordLabel.Text = "Password:"
            $objForm.Controls.Add($objPasswordLabel) 

            $objPasswordTextBox = New-Object System.Windows.Forms.TextBox 
            $objPasswordTextBox.Location = New-Object System.Drawing.Size(10,240) 
            $objPasswordTextBox.Size = New-Object System.Drawing.Size(260,20) 
            $objPasswordTextBox.Text = $cred.Password
            $objPasswordTextBox.PasswordChar = "*"
            $objForm.Controls.Add($objPasswordTextBox) 

            $objDescriptionLabel = New-Object System.Windows.Forms.Label
            $objDescriptionLabel.Location = New-Object System.Drawing.Size(10,120) 
            $objDescriptionLabel.Size = New-Object System.Drawing.Size(280,20) 
            $objDescriptionLabel.Text = "Description:"
            $objForm.Controls.Add($objDescriptionLabel) 

            $objDescriptionTextBox = New-Object System.Windows.Forms.TextBox 
            $objDescriptionTextBox.Location = New-Object System.Drawing.Size(10,140) 
            $objDescriptionTextBox.Size = New-Object System.Drawing.Size(260,20) 
            $objDescriptionTextBox.Text = $cred.Description
            $objForm.Controls.Add($objDescriptionTextBox)  

            $objGenericField1Label = New-Object System.Windows.Forms.Label
            $objGenericField1Label.Location = New-Object System.Drawing.Size(10,170) 
            $objGenericField1Label.Size = New-Object System.Drawing.Size(280,20) 
            $objGenericField1Label.Text = "Hostname/Url:"
            $objForm.Controls.Add($objGenericField1Label) 

            $objGenericField1TextBox = New-Object System.Windows.Forms.TextBox 
            $objGenericField1TextBox.Location = New-Object System.Drawing.Size(10,190) 
            $objGenericField1TextBox.Size = New-Object System.Drawing.Size(260,20) 
            $objGenericField1TextBox.Text = $cred.GenericField1
            $objForm.Controls.Add($objGenericField1TextBox) 

            $objForm.KeyPreview = $True
            $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
                {{
                    $Script:OkPressed=$OKButton.Text;
                    $Script:Title=$objTitleTextBox.Text;
                    $Script:UserName=$objUserNameTextBox.Text;
                    $Script:Description=$objDescriptionTextBox.Text;
                    $Script:GenericField1=$objGenericField1TextBox.Text;
                    $Script:Password=$objPasswordTextBox.Text;
                    $objForm.Close()}}})
            $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
                {$objForm.Close()}})

            $objForm.Topmost = $True

            $objForm.Add_Shown({$objForm.Activate()})
            [void] $objForm.ShowDialog()

            Remove-Variable objForm

            if ($Script:OkPressed -eq "OK") {
                $cred.Title = $Script:Title
                $cred.UserName = $Script:UserName
                $cred.Description = $Script:Description
                $cred.GenericField1 = $Script:GenericField1
                $cred.Password = $Script:Password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
                Set-Content -Value ($cred | ConvertTo-Json) -Encoding UTF8 -Path (Join-Path $credPath $credFileName)
                $cred.Password = $Script:Password 
            } else {
                trow
            }
        }
        return $cred
    }
}
