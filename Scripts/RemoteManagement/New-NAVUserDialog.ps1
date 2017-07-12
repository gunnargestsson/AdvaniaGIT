Function New-NAVUserDialog {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$User,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$UserNameNotEditable
    )
    PROCESS
    {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

        $Script:OkPressed = 'NO'
        $objForm = New-Object System.Windows.Forms.Form 
        $objForm.Text = $Message
        $objForm.Size = New-Object System.Drawing.Size(300,400) 
        $objForm.StartPosition = "CenterScreen"

        $OKButton = New-Object System.Windows.Forms.Button
        $OKButton.Location = New-Object System.Drawing.Size(75,330)
        $OKButton.Size = New-Object System.Drawing.Size(75,23)
        $OKButton.Text = "OK"
        $OKButton.Add_Click({
            $Script:OkPressed=$OKButton.Text;
            $Script:UserName=$objUserNameTextBox.Text;
            $Script:FullName=$objFullNameTextBox.Text;
            $Script:AuthenticationEMail=$objAuthenticationEMailTextBox.Text;
            $Script:LicenseType=$objLicenseTypeComboBox.SelectedItem;
            $Script:State=$objStateComboBox.SelectedItem;
            $objForm.Close()})
        $objForm.Controls.Add($OKButton)

        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Size(150,330)
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
        $objUserNameTextBox.Text = $User.UserName
        if ($UserNameNotEditable) { $objUserNameTextBox.Enabled = $false }
        $objForm.Controls.Add($objUserNameTextBox)
        
        $objFullNameLabel = New-Object System.Windows.Forms.Label
        $objFullNameLabel.Location = New-Object System.Drawing.Size(10,70) 
        $objFullNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objFullNameLabel.Text = "Full Name:"
        $objForm.Controls.Add($objFullNameLabel) 

        $objFullNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objFullNameTextBox.Location = New-Object System.Drawing.Size(10,90) 
        $objFullNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objFullNameTextBox.Text = $User.FullName
        $objForm.Controls.Add($objFullNameTextBox)  

        $objAuthenticationEMailLabel = New-Object System.Windows.Forms.Label
        $objAuthenticationEMailLabel.Location = New-Object System.Drawing.Size(10,120) 
        $objAuthenticationEMailLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objAuthenticationEMailLabel.Text = "Authentication EMail:"
        $objForm.Controls.Add($objAuthenticationEMailLabel) 

        $objAuthenticationEMailTextBox = New-Object System.Windows.Forms.TextBox 
        $objAuthenticationEMailTextBox.Location = New-Object System.Drawing.Size(10,140) 
        $objAuthenticationEMailTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objAuthenticationEMailTextBox.Text = $User.AuthenticationEMail
        $objForm.Controls.Add($objAuthenticationEMailTextBox)  

        $objLicenseTypeLabel = New-Object System.Windows.Forms.Label
        $objLicenseTypeLabel.Location = New-Object System.Drawing.Size(10,170) 
        $objLicenseTypeLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objLicenseTypeLabel.Text = "License Type:"
        $objForm.Controls.Add($objLicenseTypeLabel) 

        $objLicenseTypeComboBox = New-Object System.Windows.Forms.ComboBox
        $objLicenseTypeComboBox.Location = New-Object System.Drawing.Size(10,190) 
        $objLicenseTypeComboBox.Size = New-Object System.Drawing.Size(260,20) 
        $Item = $objLicenseTypeComboBox.Items.Add("Full")
        $Item = $objLicenseTypeComboBox.Items.Add("Limited")
        $objLicenseTypeComboBox.SelectedItem = $User.LicenseType
        $objForm.Controls.Add($objLicenseTypeComboBox)  

        $objStateLabel = New-Object System.Windows.Forms.Label
        $objStateLabel.Location = New-Object System.Drawing.Size(10,220) 
        $objStateLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objStateLabel.Text = "State:"
        $objForm.Controls.Add($objStateLabel) 

        $objStateComboBox = New-Object System.Windows.Forms.ComboBox
        $objStateComboBox.Location = New-Object System.Drawing.Size(10,240) 
        $objStateComboBox.Size = New-Object System.Drawing.Size(260,20) 
        $Item = $objStateComboBox.Items.Add("Enabled")
        $Item = $objStateComboBox.Items.Add("Disabled")
        $objStateComboBox.SelectedItem = $User.State
        $objForm.Controls.Add($objStateComboBox)  

        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
            {{
                $Script:OkPressed=$OKButton.Text;
                $Script:UserName=$objUserNameTextBox.Text;
                $Script:FullName=$objFullNameTextBox.Text;
                $Script:AuthenticationEMail=$objAuthenticationEMailTextBox.Text;
                $Script:LicenseType=$objLicenseTypeComboBox.SelectedItem;
                $Script:State=$objStateComboBox.SelectedItem;
                $objForm.Close()}}})
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
            {$objForm.Close()}})

        $objForm.Topmost = $True

        $objForm.Add_Shown({$objForm.Activate()})
        [void] $objForm.ShowDialog()

        Remove-Variable objForm
        $NewUser = New-Object -TypeName PSObject
        $NewUser | Add-Member -MemberType NoteProperty -Name UserName -Value $UserName        
        $NewUser | Add-Member -MemberType NoteProperty -Name FullName -Value $FullName
        $NewUser | Add-Member -MemberType NoteProperty -Name AuthenticationEMail -Value $AuthenticationEMail
        $NewUser | Add-Member -MemberType NoteProperty -Name LicenseType -Value $LicenseType
        $NewUser | Add-Member -MemberType NoteProperty -Name State -Value $State
        $NewUser | Add-Member -MemberType NoteProperty -Name OkPressed -Value $Script:OkPressed
        return $NewUser
    }
}
