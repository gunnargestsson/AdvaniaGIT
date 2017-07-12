Function New-NAVDatabaseDialog {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Database
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
            $Script:DatabaseName=$objDatabaseNameTextBox.Text;
            $Script:DatabaseServerName=$objDatabaseServerNameTextBox.Text;
            $Script:DatabaseInstanceName=$objDatabaseInstanceNameTextBox.Text;
            $Script:DatabaseUserName=$objDatabaseUserNameTextBox.Text;
            $Script:DatabasePassword=$objDatabasePasswordTextBox.Text;
            $objForm.Close()})
        $objForm.Controls.Add($OKButton)

        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Size(150,330)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.Add_Click({$objForm.Close()})
        $objForm.Controls.Add($CancelButton)

        $objDatabaseNameLabel = New-Object System.Windows.Forms.Label
        $objDatabaseNameLabel.Location = New-Object System.Drawing.Size(10,20) 
        $objDatabaseNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objDatabaseNameLabel.Text = "Database Name:"
         
        $objForm.Controls.Add($objDatabaseNameLabel) 

        $objDatabaseNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objDatabaseNameTextBox.Location = New-Object System.Drawing.Size(10,40) 
        $objDatabaseNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objDatabaseNameTextBox.Text = $Database.DatabaseName
        if ($DatabaseNameNotEditable) { $objDatabaseNameTextBox.Enabled = $false }
        $objForm.Controls.Add($objDatabaseNameTextBox)
        
        $objDatabaseServerNameLabel = New-Object System.Windows.Forms.Label
        $objDatabaseServerNameLabel.Location = New-Object System.Drawing.Size(10,70) 
        $objDatabaseServerNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objDatabaseServerNameLabel.Text = "Database Server Name:"
        $objForm.Controls.Add($objDatabaseServerNameLabel) 

        $objDatabaseServerNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objDatabaseServerNameTextBox.Location = New-Object System.Drawing.Size(10,90) 
        $objDatabaseServerNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objDatabaseServerNameTextBox.Text = $Database.DatabaseServerName
        $objForm.Controls.Add($objDatabaseServerNameTextBox)  

        $objDatabaseInstanceNameLabel = New-Object System.Windows.Forms.Label
        $objDatabaseInstanceNameLabel.Location = New-Object System.Drawing.Size(10,120) 
        $objDatabaseInstanceNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objDatabaseInstanceNameLabel.Text = "Database Instance Name:"
        $objForm.Controls.Add($objDatabaseInstanceNameLabel) 

        $objDatabaseInstanceNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objDatabaseInstanceNameTextBox.Location = New-Object System.Drawing.Size(10,140) 
        $objDatabaseInstanceNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objDatabaseInstanceNameTextBox.Text = $Database.DatabaseInstanceName
        $objForm.Controls.Add($objDatabaseInstanceNameTextBox)  

        $objDatabaseUserNameLabel = New-Object System.Windows.Forms.Label
        $objDatabaseUserNameLabel.Location = New-Object System.Drawing.Size(10,170) 
        $objDatabaseUserNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objDatabaseUserNameLabel.Text = "Database User Name:"
        $objForm.Controls.Add($objDatabaseUserNameLabel) 

        $objDatabaseUserNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objDatabaseUserNameTextBox.Location = New-Object System.Drawing.Size(10,190) 
        $objDatabaseUserNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objDatabaseUserNameTextBox.Text = $Database.DatabaseUserName
        $objForm.Controls.Add($objDatabaseUserNameTextBox)
        
        $objDatabasePasswordLabel = New-Object System.Windows.Forms.Label
        $objDatabasePasswordLabel.Location = New-Object System.Drawing.Size(10,220) 
        $objDatabasePasswordLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objDatabasePasswordLabel.Text = "Database Password:"
        $objForm.Controls.Add($objDatabasePasswordLabel) 

        $objDatabasePasswordTextBox = New-Object System.Windows.Forms.TextBox 
        $objDatabasePasswordTextBox.Location = New-Object System.Drawing.Size(10,240) 
        $objDatabasePasswordTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objDatabasePasswordTextBox.Text = $Database.DatabasePassword
        $objDatabasePasswordTextBox.PasswordChar = '*'
        $objForm.Controls.Add($objDatabasePasswordTextBox)

        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
            {{
                $Script:OkPressed=$OKButton.Text;
                $Script:DatabaseName=$objDatabaseNameTextBox.Text;
                $Script:DatabaseServerName=$objDatabaseServerNameTextBox.Text;
                $Script:DatabaseInstanceName=$objDatabaseInstanceNameTextBox.Text;
                $Script:DatabaseUserName=$objDatabaseUserNameTextBox.Text;
                $Script:DatabasePassword=$objDatabasePasswordTextBox.Text;
                $objForm.Close()}}})
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
            {$objForm.Close()}})

        $objForm.Topmost = $True

        $objForm.Add_Shown({$objForm.Activate()})
        [void] $objForm.ShowDialog()
        Remove-Variable objForm

        $NewDatabase = New-Object -TypeName PSObject
        $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseName -Value $DatabaseName        
        $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseServerName -Value $DatabaseServerName
        $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseInstanceName -Value $DatabaseInstanceName
        $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabaseUserName -Value $DatabaseUserName
        $NewDatabase | Add-Member -MemberType NoteProperty -Name DatabasePassword -Value $DatabasePassword
        $NewDatabase | Add-Member -MemberType NoteProperty -Name OkPressed -Value $Script:OkPressed
        return $NewDatabase
    }
}
