Function New-InstanceSettingsDialog {
    param(
        [Parameter(Mandatory=$True, ValueFromPipelineByPropertyname=$true)]
        [String]$Message
    )
    PROCESS
    {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

        $Script:OkPressed = 'NO'                        
        $objForm = New-Object System.Windows.Forms.Form 
        $objForm.Text = $Message
        $objForm.Size = New-Object System.Drawing.Size(300,300) 
        $objForm.StartPosition = "CenterScreen"

        $OKButton = New-Object System.Windows.Forms.Button
        $OKButton.Location = New-Object System.Drawing.Size(75,230)
        $OKButton.Size = New-Object System.Drawing.Size(75,23)
        $OKButton.Text = "OK"
        $OKButton.Add_Click({
            $Script:OkPressed=$OKButton.Text;
            $Script:ServerInstance=$ObjServerInstanceTextBox.Text;
            $objForm.Close()})
        $objForm.Controls.Add($OKButton)

        $CancelButton = New-Object System.Windows.Forms.Button
        $CancelButton.Location = New-Object System.Drawing.Size(150,230)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.Add_Click({$objForm.Close()})
        $objForm.Controls.Add($CancelButton)

        $ObjServerInstanceLabel = New-Object System.Windows.Forms.Label
        $ObjServerInstanceLabel.Location = New-Object System.Drawing.Size(10,20) 
        $ObjServerInstanceLabel.Size = New-Object System.Drawing.Size(280,20) 
        $ObjServerInstanceLabel.Text = "Type new Instance Name:"
         
        $objForm.Controls.Add($ObjServerInstanceLabel) 

        $ObjServerInstanceTextBox = New-Object System.Windows.Forms.TextBox 
        $ObjServerInstanceTextBox.Location = New-Object System.Drawing.Size(10,40) 
        $ObjServerInstanceTextBox.Size = New-Object System.Drawing.Size(260,20) 
        $ObjServerInstanceTextBox.Text = ""
        $objForm.Controls.Add($ObjServerInstanceTextBox)
        
        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
            {{
                $Script:OkPressed=$OKButton.Text;
                $Script:ServerInstance=$ObjServerInstanceTextBox.Text;
                $objForm.Close()}}})
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
            {$objForm.Close()}})

        $objForm.Topmost = $True

        $objForm.Add_Shown({$objForm.Activate()})
        [void] $objForm.ShowDialog()

        Remove-Variable objForm
        $InstanceSettings = New-Object -TypeName PSObject
        $InstanceSettings | Add-Member -MemberType NoteProperty -Name ServerInstance -Value $Script:ServerInstance
        $InstanceSettings | Add-Member -MemberType NoteProperty -Name OkPressed -Value $Script:OkPressed
        $InstanceSettings | Add-Member -MemberType NoteProperty -Name TenantList -Value @()
        return $InstanceSettings
    }
}
