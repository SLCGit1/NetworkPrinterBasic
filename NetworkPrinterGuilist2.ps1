<#
.SYNOPSIS
    Fixed Responsive Network Printer Installer GUI

.DESCRIPTION
    This version properly anchors and resizes the ListView and buttons across the window.
#>

param (
    [string]$PrintServer = "PrintServerFQDN"
)

Add-Type -AssemblyName System.Windows.Forms

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Network Printer Installer"
$form.Size = New-Object System.Drawing.Size(800, 500)
$form.StartPosition = "CenterScreen"

# Create ListView
$listView = New-Object System.Windows.Forms.ListView
$listView.View = 'Details'
$listView.FullRowSelect = $true
$listView.MultiSelect = $true
$listView.CheckBoxes = $false
$listView.Location = New-Object System.Drawing.Point(10, 10)
$listView.Size = New-Object System.Drawing.Size(760, 380)
$listView.Anchor = 'Top, Bottom, Left, Right'
$listView.Columns.Add("Printer Share Name", 350) | Out-Null
$listView.Columns.Add("Location", 390) | Out-Null
$form.Controls.Add($listView)

# Install Button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install Selected"
$installButton.Size = New-Object System.Drawing.Size(140, 30)
$installButton.Location = New-Object System.Drawing.Point(10, 400)
$installButton.Anchor = 'Bottom, Left'
$form.Controls.Add($installButton)

# Exit Button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Size = New-Object System.Drawing.Size(100, 30)
$exitButton.Location = New-Object System.Drawing.Point(160, 400)
$exitButton.Anchor = 'Bottom, Left'
$exitButton.Add_Click({ $form.Close() })
$form.Controls.Add($exitButton)

# Adjust columns on resize
$form.Add_Resize({
    $listView.Columns[0].Width = [int]($listView.Width * 0.45)
    $listView.Columns[1].Width = [int]($listView.Width * 0.50)
})

# Load printers dynamically
$tempFile = "$env:TEMP\netview_temp.txt"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c net view \\$PrintServer > `"$tempFile`"" -NoNewWindow -Wait

if (Test-Path $tempFile) {
    Get-Content $tempFile | ForEach-Object {
        if ($_ -match '^\s*\S+\s+Print\s+') {
            $parts = $_ -split '\s{2,}'
            $share = $parts[0].Trim()
            $comment = if ($parts.Count -gt 2) { $parts[2].Trim() } else { "N/A" }
            if ([string]::IsNullOrWhiteSpace($comment) -or $comment -eq $share) { $comment = "N/A" }
            $item = New-Object System.Windows.Forms.ListViewItem($share)
            $item.SubItems.Add($comment) | Out-Null
            $listView.Items.Add($item) | Out-Null
        }
    }
    Remove-Item $tempFile -Force
} else {
    [System.Windows.Forms.MessageBox]::Show("Unable to reach print server: $PrintServer", "Error", "OK", "Error")
    return
}

# Install selected printers
$installButton.Add_Click({
    $selected = $listView.SelectedItems
    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one printer.", "No Selection", "OK", "Information")
        return
    }

    foreach ($item in $selected) {
        $printer = $item.Text
        $path = "\\$PrintServer\$printer"
        Write-Host "Installing: $path"
        Start-Process -FilePath "rundll32.exe" -ArgumentList "printui.dll,PrintUIEntry /in /n`"$path`"" -NoNewWindow -Wait
    }

    [System.Windows.Forms.MessageBox]::Show("Installation complete.", "Success", "OK", "Information")
})

$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
