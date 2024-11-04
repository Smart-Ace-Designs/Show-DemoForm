<#
============================================================================================================================
Script: Show-DemoForm
Author: Smart Ace

Notes:
This script is used to demonstrate a basic ScriptoForm that has been customized after deployment.
============================================================================================================================
#>

#region Settings
$SUPPORT_CONTACT = "Smart Ace"
#endregion

#region Assemblies
Add-Type -AssemblyName System.Windows.Forms
#endregion

#region Appearance
[System.Windows.Forms.Application]::EnableVisualStyles()
#endregion

#region Controls
$FormMain = New-Object -TypeName System.Windows.Forms.Form
$GroupBoxMain = New-Object -TypeName System.Windows.Forms.GroupBox
$LabelServerName = New-Object -TypeName System.Windows.Forms.Label
$TextBoxServerName = New-Object -TypeName System.Windows.Forms.TextBox
$ButtonRun = New-Object -TypeName System.Windows.Forms.Button
$ButtonClose = New-Object -TypeName System.Windows.Forms.Button
$StatusStripMain = New-Object -TypeName System.Windows.Forms.StatusStrip
$ToolStripStatusLabelMain = New-Object -TypeName System.Windows.Forms.ToolStripStatusLabel
$ErrorProviderMain = New-Object -TypeName System.Windows.Forms.ErrorProvider
#endregion

#region Forms
$ShowFormMain =
{
    $FormWidth = 330
    $FormHeight = 260

    $FormMain.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $PID).Path)
    $FormMain.Text = "ScriptoForm Demo"
    $FormMain.Font = New-Object -TypeName System.Drawing.Font("MS Sans Serif",8)
    $FormMain.ClientSize = New-Object -TypeName System.Drawing.Size($FormWidth,$FormHeight)
    $FormMain.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $FormMain.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $FormMain.MaximizeBox = $false
    $FormMain.AcceptButton = $ButtonRun
    $FormMain.CancelButton = $ButtonClose
    $FormMain.Add_Shown($FormMain_Shown)

    $GroupBoxMain.Location = New-Object -TypeName System.Drawing.Point(10,5)
    $GroupBoxMain.Size = New-Object -TypeName System.Drawing.Size(($FormWidth - 20),($FormHeight - 80))
    $FormMain.Controls.Add($GroupBoxMain)

    $LabelServerName.Location = New-Object -TypeName System.Drawing.Point(15,15)
    $LabelServerName.AutoSize = $true
    $LabelServerName.Text = "Server Name:"
    $GroupBoxMain.Controls.Add($LabelServerName)
    
    $TextBoxServerName.Location = New-Object -TypeName System.Drawing.Point(15,35)
    $TextBoxServerName.Size = New-Object -TypeName System.Drawing.Size(($FormWidth - 50),20)
    $TextBoxServerName.TabIndex = 0
    $TextBoxServerName.CharacterCasing = [System.Windows.Forms.CharacterCasing]::Upper
    $TextBoxServerName.MaxLength = 15
    $TextBoxServerName.Add_TextChanged($TextBoxServerName_TextChanged)
    $GroupBoxMain.Controls.Add($TextBoxServerName)

    $ButtonRun.Location = New-Object -TypeName System.Drawing.Point(($FormWidth - 175),($FormHeight - 60))
    $ButtonRun.Size = New-Object -TypeName System.Drawing.Size(75,25)
    $ButtonRun.TabIndex = 100
    $ButtonRun.Enabled = $false
    $ButtonRun.Text = "Run"
    $ButtonRun.Add_Click($ButtonRun_Click)
    $FormMain.Controls.Add($ButtonRun)

    $ButtonClose.Location = New-Object -TypeName System.Drawing.Point(($FormWidth - 85),($FormHeight - 60))
    $ButtonClose.Size = New-Object -TypeName System.Drawing.Size(75,25)
    $ButtonClose.TabIndex = 101
    $ButtonClose.Text = "Close"
    $ButtonClose.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $FormMain.Controls.Add($ButtonClose)

    $StatusStripMain.SizingGrip = $false
    $StatusStripMain.Font = New-Object -TypeName System.Drawing.Font("MS Sans Serif",8)
    [void]$StatusStripMain.Items.Add($ToolStripStatusLabelMain)
    $FormMain.Controls.Add($StatusStripMain)

    [void]$FormMain.ShowDialog()
    $FormMain.Dispose()
}
#endregion

#region Functions
#endregion

#region Handlers
$FormMain_Shown =
{
    $ToolStripStatusLabelMain.Text = "Ready"
    $StatusStripMain.Update()
    $FormMain.Activate()
}

$TextBoxServerName_TextChanged =
{
    if ($TextBoxServerName.TextLength -eq 0)
    {
        $ErrorProviderMain.Clear()
        $ButtonRun.Enabled = $false
    }
    elseif ($TextBoxServerName.Text -match "[^a-z0-9A-Z\-]")
    {
        $ErrorProviderMain.SetIconPadding($TextBoxServerName,-20)
        $ErrorProviderMain.SetError($TextBoxServerName,"The server name contains an invalid character.")
        $ButtonRun.Enabled = $false
    }
    else
    {
        $ErrorProviderMain.Clear()
        $ButtonRun.Enabled = $true
    }
}

$ButtonRun_Click =
{
    $ToolStripStatusLabelMain.Text = "Working...please wait"
    $FormMain.Controls | Where-Object {$PSItem -isnot [System.Windows.Forms.StatusStrip]} | ForEach-Object {$PSItem.Enabled = $false}
    $FormMain.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    [System.Windows.Forms.Application]::DoEvents()

    try
    {
        Start-Sleep -Seconds 2
        [void][System.Windows.Forms.MessageBox]::Show(
            "Simulation of work completed.",
            "Results",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
    catch
    {
        [void][System.Windows.Forms.MessageBox]::Show(
            $PSItem.Exception.Message + "`n`nPlease contact $SUPPORT_CONTACT for technical support.",
            "Exception",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }

    $FormMain.Controls | ForEach-Object {$PSItem.Enabled = $true}
    $FormMain.ResetCursor()
    $TextBoxServerName.Clear()
    $TextBoxServerName.Focus()
    $ToolStripStatusLabelMain.Text = "Ready"
    $StatusStripMain.Update()
}
#endregion

#region Main
Invoke-Command -ScriptBlock $ShowFormMain
#endregion
