Function New-NAVCompanyDialog {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message,
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [PSObject]$Company,
        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyname=$true)]
        [Switch]$CompanyNameNotEditable
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
            $Script:CompanyName=$objCompanyNameTextBox.Text;
            $objForm.Close()})
        $objForm.Controls.Add($OKButton)

        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Size(150,330)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.Add_Click({$objForm.Close()})
        $objForm.Controls.Add($CancelButton)

        $objCompanyNameLabel = New-Object System.Windows.Forms.Label
        $objCompanyNameLabel.Location = New-Object System.Drawing.Size(10,20) 
        $objCompanyNameLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objCompanyNameLabel.Text = "Company Name:"
         
        $objForm.Controls.Add($objCompanyNameLabel) 

        $objCompanyNameTextBox = New-Object System.Windows.Forms.TextBox 
        $objCompanyNameTextBox.Location = New-Object System.Drawing.Size(10,40) 
        $objCompanyNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $objCompanyNameTextBox.Text = $Company.CompanyName
        if ($CompanyNameNotEditable) { $objCompanyNameTextBox.Enabled = $false }
        $objForm.Controls.Add($objCompanyNameTextBox)
        
        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
            {{
                $Script:OkPressed=$OKButton.Text;
                $Script:CompanyName=$objCompanyNameTextBox.Text;
                $objForm.Close()}}})
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
            {$objForm.Close()}})

        $objForm.Topmost = $True

        $objForm.Add_Shown({$objForm.Activate()})
        [void] $objForm.ShowDialog()

        Remove-Variable objForm
        $NewCompany = New-Object -TypeName PSObject
        $NewCompany | Add-Member -MemberType NoteProperty -Name CompanyName -Value $CompanyName        
        $NewCompany | Add-Member -MemberType NoteProperty -Name EvaluationCompany -Value $Company.EvaluationCompany
        $NewCompany | Add-Member -MemberType NoteProperty -Name OkPressed -Value $Script:OkPressed
        return $NewCompany
    }
}
