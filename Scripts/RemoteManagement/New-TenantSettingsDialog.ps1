Function New-TenantSettingsDialog {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$TenantSettings,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$TenantIdNotEditable
    )
    PROCESS
    {

        $Id = $TenantSettings.Id
        $CustomerRegistrationNo = $TenantSettings.CustomerRegistrationNo
        $CustomerName = $TenantSettings.CustomerName
        $CustomerEMail = $TenantSettings.CustomerEMail
        $PasswordId = $TenantSettings.PasswordId
        $LicenseNo = $TenantSettings.LicenseNo
        $ClickOnceHost = $TenantSettings.ClickOnceHost
        $Language = $TenantSettings.Language

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
            $Script:Id=$objIdTextBox.Text;
            $Script:CustomerRegistrationNo=$objCustomerRegistrationNoTextBox.Text;
            $Script:CustomerName=$objCustomerNameTextBox.Text;
            $Script:CustomerEMail=$objCustomerEMailTextBox.Text;
            $Script:PasswordId=$objPasswordIdTextBox.Text;
            $Script:LicenseNo=$objLicenseNoTextBox.Text;
            $Script:ClickOnceHost=$objClickOnceHostTextBox.Text;
            $Script:Language=$objLanguageTextBox.Text;
            $objForm.Close()})
        $objForm.Controls.Add($OKButton)

        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Size(150,480)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.Add_Click({$objForm.Close()})
        $objForm.Controls.Add($CancelButton)

        $objIdLabel = New-Object System.Windows.Forms.Label
        $objIdLabel.Location = New-Object System.Drawing.Size(10,20) 
        $objIdLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objIdLabel.Text = "Tenant:"
         
        $objForm.Controls.Add($objIdLabel) 

        $objIdTextBox = New-Object System.Windows.Forms.TextBox 
        $objIdTextBox.Location = New-Object System.Drawing.Size(10,40) 
        $objIdTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objIdTextBox.Text = $TenantSettings.Id
        if ($TenantIdNotEditable) { $objIdTextBox.Enabled = $false }
        $objForm.Controls.Add($objIdTextBox)
        
        $objCustomerRegistrationNoLabel = New-Object System.Windows.Forms.Label
        $objCustomerRegistrationNoLabel.Location = New-Object System.Drawing.Size(10,70) 
        $objCustomerRegistrationNoLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objCustomerRegistrationNoLabel.Text = "Customer Registration No.:"
        $objForm.Controls.Add($objCustomerRegistrationNoLabel) 

        $objCustomerRegistrationNoTextBox = New-Object System.Windows.Forms.TextBox 
        $objCustomerRegistrationNoTextBox.Location = New-Object System.Drawing.Size(10,90) 
        $objCustomerRegistrationNoTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objCustomerRegistrationNoTextBox.Text = $TenantSettings.CustomerRegistrationNo
        $objForm.Controls.Add($objCustomerRegistrationNoTextBox)  

        $objCustomerNameLabel = New-Object System.Windows.Forms.Label
        $objCustomerNameLabel.Location = New-Object System.Drawing.Size(10,120) 
        $objCustomerNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objCustomerNameLabel.Text = "Customer Name:"
        $objForm.Controls.Add($objCustomerNameLabel) 

        $objCustomerNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objCustomerNameTextBox.Location = New-Object System.Drawing.Size(10,140) 
        $objCustomerNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objCustomerNameTextBox.Text = $TenantSettings.CustomerName
        $objForm.Controls.Add($objCustomerNameTextBox)  

        $objCustomerEMailLabel = New-Object System.Windows.Forms.Label
        $objCustomerEMailLabel.Location = New-Object System.Drawing.Size(10,170) 
        $objCustomerEMailLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objCustomerEMailLabel.Text = "Customer EMail:"
        $objForm.Controls.Add($objCustomerEMailLabel) 

        $objCustomerEMailTextBox = New-Object System.Windows.Forms.TextBox 
        $objCustomerEMailTextBox.Location = New-Object System.Drawing.Size(10,190) 
        $objCustomerEMailTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objCustomerEMailTextBox.Text = $TenantSettings.CustomerEMail
        $objForm.Controls.Add($objCustomerEMailTextBox) 

        $objPasswordIdLabel = New-Object System.Windows.Forms.Label
        $objPasswordIdLabel.Location = New-Object System.Drawing.Size(10,220) 
        $objPasswordIdLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objPasswordIdLabel.Text = "Password Id:"
        $objForm.Controls.Add($objPasswordIdLabel) 

        $objPasswordIdTextBox = New-Object System.Windows.Forms.TextBox 
        $objPasswordIdTextBox.Location = New-Object System.Drawing.Size(10,240) 
        $objPasswordIdTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objPasswordIdTextBox.Text = $TenantSettings.PasswordId
        $objForm.Controls.Add($objPasswordIdTextBox) 

        $objLicenseNoLabel = New-Object System.Windows.Forms.Label
        $objLicenseNoLabel.Location = New-Object System.Drawing.Size(10,270) 
        $objLicenseNoLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objLicenseNoLabel.Text = "License No:"
        $objForm.Controls.Add($objLicenseNoLabel) 

        $objLicenseNoTextBox = New-Object System.Windows.Forms.TextBox 
        $objLicenseNoTextBox.Location = New-Object System.Drawing.Size(10,290) 
        $objLicenseNoTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objLicenseNoTextBox.Text = $TenantSettings.LicenseNo
        $objForm.Controls.Add($objLicenseNoTextBox) 

        $objClickOnceHostLabel = New-Object System.Windows.Forms.Label
        $objClickOnceHostLabel.Location = New-Object System.Drawing.Size(10,320) 
        $objClickOnceHostLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objClickOnceHostLabel.Text = "ClickOnce Url:"
        $objForm.Controls.Add($objClickOnceHostLabel) 

        $objClickOnceHostTextBox = New-Object System.Windows.Forms.TextBox 
        $objClickOnceHostTextBox.Location = New-Object System.Drawing.Size(10,340) 
        $objClickOnceHostTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objClickOnceHostTextBox.Text = $TenantSettings.ClickOnceHost
        $objForm.Controls.Add($objClickOnceHostTextBox)  

        $objLanguageLabel = New-Object System.Windows.Forms.Label
        $objLanguageLabel.Location = New-Object System.Drawing.Size(10,370) 
        $objLanguageLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objLanguageLabel.Text = "Tenant Language:"
        $objForm.Controls.Add($objLanguageLabel) 

        $objLanguageTextBox = New-Object System.Windows.Forms.TextBox 
        $objLanguageTextBox.Location = New-Object System.Drawing.Size(10,390) 
        $objLanguageTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objLanguageTextBox.Text = $TenantSettings.Language
        $objForm.Controls.Add($objLanguageTextBox)  

        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
            {{
                $Script:OkPressed=$OKButton.Text;
                $Script:Id=$objIdTextBox.Text;
                $Script:CustomerRegistrationNo=$objCustomerRegistrationNoTextBox.Text;
                $Script:CustomerName=$objCustomerNameTextBox.Text;
                $Script:CustomerEMail=$objCustomerEMailTextBox.Text;
                $Script:PasswordId=$objPasswordIdTextBox.Text;
                $Script:LicenseNo=$objLicenseNoTextBox.Text;
                $Script:ClickOnceHost=$objClickOnceHostTextBox.Text;
                $Script:Language=$objLanguageTextBox.Text;
                $objForm.Close()}}})
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
            {$objForm.Close()}})

        $objForm.Topmost = $True

        $objForm.Add_Shown({$objForm.Activate()})
        [void] $objForm.ShowDialog()

        Remove-Variable objForm
        $TenantSettings.Id = $Script:Id
        $TenantSettings.CustomerRegistrationNo = $Script:CustomerRegistrationNo
        $TenantSettings.CustomerName = $Script:CustomerName
        $TenantSettings.CustomerEMail = $Script:CustomerEMail
        $TenantSettings.PasswordId = $Script:PasswordId
        $TenantSettings.LicenseNo = $Script:LicenseNo
        $TenantSettings.ClickOnceHost = $Script:ClickOnceHost
        $TenantSettings.Language = $Script:Language
        $TenantSettings | Add-Member -MemberType NoteProperty -Name OkPressed -Value $Script:OkPressed

        return $TenantSettings
    }
}
