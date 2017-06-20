Function New-UserDialog {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message
    )
    PROCESS
    {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

        $objForm = New-Object System.Windows.Forms.Form 
        $objForm.Text = $Message
        $objForm.Size = New-Object System.Drawing.Size(300,300) 
        $objForm.StartPosition = "CenterScreen"

        $OKButton = New-Object System.Windows.Forms.Button
        $OKButton.Location = New-Object System.Drawing.Size(75,230)
        $OKButton.Size = New-Object System.Drawing.Size(75,23)
        $OKButton.Text = "OK"
        $OKButton.Add_Click({
            $Script:UserName=$objUserNameTextBox.Text;
            $Script:FullName=$objFullNameTextBox.Text;
            $Script:AuthenticationEMail=$objAuthenticationEMailTextBox.Text;
            $Script:LicenseType=$objLicenseTypeComboBox.SelectedText;
            $objForm.Close()})
        $objForm.Controls.Add($OKButton)

        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Size(150,230)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.Add_Click({$objForm.Close()})
        $objForm.Controls.Add($CancelButton)

        $objUserNameLabel = New-Object System.Windows.Forms.Label
        $objUserNameLabel.Location = New-Object System.Drawing.Size(10,20) 
        $objUserNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objUserNameLabel.Text = "User Name:"
        $objForm.Controls.Add($objUserNameLabel) 

        $objUserNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objUserNameTextBox.Location = New-Object System.Drawing.Size(10,40) 
        $objUserNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objForm.Controls.Add($objUserNameTextBox)
        
        $objFullNameLabel = New-Object System.Windows.Forms.Label
        $objFullNameLabel.Location = New-Object System.Drawing.Size(10,70) 
        $objFullNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objFullNameLabel.Text = "Full Name:"
        $objForm.Controls.Add($objFullNameLabel) 

        $objFullNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objFullNameTextBox.Location = New-Object System.Drawing.Size(10,90) 
        $objFullNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objForm.Controls.Add($objFullNameTextBox)  

        $objAuthenticationEMailLabel = New-Object System.Windows.Forms.Label
        $objAuthenticationEMailLabel.Location = New-Object System.Drawing.Size(10,120) 
        $objAuthenticationEMailLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objAuthenticationEMailLabel.Text = "Authentication EMail:"
        $objForm.Controls.Add($objAuthenticationEMailLabel) 

        $objAuthenticationEMailTextBox = New-Object System.Windows.Forms.TextBox 
        $objAuthenticationEMailTextBox.Location = New-Object System.Drawing.Size(10,140) 
        $objAuthenticationEMailTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objForm.Controls.Add($objAuthenticationEMailTextBox)  

        $objLicenseTypeLabel = New-Object System.Windows.Forms.Label
        $objLicenseTypeLabel.Location = New-Object System.Drawing.Size(10,170) 
        $objLicenseTypeLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objLicenseTypeLabel.Text = "License Type:"
        $objForm.Controls.Add($objLicenseTypeLabel) 

        $objLicenseTypeComboBox = New-Object System.Windows.Forms.ComboBox
        $objLicenseTypeComboBox.Location = New-Object System.Drawing.Size(10,190) 
        $objLicenseTypeComboBox.Size = New-Object System.Drawing.Size(260,20) 
        $Item = $objLicenseTypeComboBox.Items.Add("Full User")
        $Item = $objLicenseTypeComboBox.Items.Add("Limited User")
        $objLicenseTypeComboBox.SelectedText = "Full User"
        $objForm.Controls.Add($objLicenseTypeComboBox)  

        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
            {{
                $Script:UserName=$objUserNameTextBox.Text;
                $Script:FullName=$objFullNameTextBox.Text;
                $Script:AuthenticationEMail=$objAuthenticationEMailTextBox.Text;
                $Script:LicenseType=$objLicenseTypeComboBox.SelectedText;
                $objForm.Close()}}})
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
            {$objForm.Close()}})

        $objForm.Topmost = $True

        $objForm.Add_Shown({$objForm.Activate()})
        [void] $objForm.ShowDialog()

        $NewUser = New-Object -TypeName PSObject
        $NewUser | Add-Member -MemberType NoteProperty -Name UserName -Value $UserName        
        $NewUser | Add-Member -MemberType NoteProperty -Name FullName -Value $FullName
        $NewUser | Add-Member -MemberType NoteProperty -Name AuthenticationEMail -Value $AuthenticationEMail
        $NewUser | Add-Member -MemberType NoteProperty -Name LicenseType -Value $LicenseType
        return $NewUser
    }
}

New-UserDialog -Message "New User for ADIS"