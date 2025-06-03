# NetworkSharedPrinterBasic(No Admin Required)

## Overview

This PowerShell script provides a graphical interface (GUI) that allows users to view, select, and install shared network printers from a remote print server. It is specifically designed to work **without requiring administrative privileges**. The script dynamically queries available printers via `net view`, extracts share names and comments, and presents them in a list.

---

## 📦 Features

- No admin rights required
- Dynamically retrieves printer shares from a remote server
- Displays printer share names and descriptive comments (location/model)
- GUI interface with "Install Selected" and "Exit" buttons
- Uses built-in Windows `printui.dll` for printer installation
- Dynamic detection of shared printers from a remote SMB print server
- GUI-based selection with multi-column list view
- Automatic printer installation using `Add-Printer`
- Supports silent mode, auto-install, and force reinstall flags
- Fallback printer list if server lookup fails
- Supports non-admin users (install via Point and Print)
- Responsive layout with stretch and resize handling
- Modernized look using `System.Windows.Forms` with anchors
- Full debug logging and CLI param support
---

## 🔧 Requirements

- Windows OS with PowerShell
- Network access to the print server
- Shared printers available via `net view \\\\printserver`

---

## 🚀 Usage

### Basic Run (interactive GUI):

```powershell
.\NNetworkPrinterGuilist2.ps1
```

This will:
- Query the default print server (`PrintServerFQDN`)
- Show a GUI list of available printers
- Let you select one or more printers to install

---

### Run with Specific Print Server:

```powershell
.\NetworkPrinterGuilist2.ps1 -PrintServer "my-print-server"
```

Replace `"my-print-server"` with your print server's hostname or IP.

---

### Optional Parameters

| Parameter        | Description                                                             |
|------------------|-------------------------------------------------------------------------|
| `-PrintServer`   | Override the default print server address                               |
| `-Silent`        | Run silently (no GUI); ignored unless combined with `-AutoInstall`      |
| `-AutoInstall`   | Automatically install all retrieved printers (requires `-Silent`)       |
| `-ForceReinstall`| (future use) Force reinstall if already installed                       |
| `-ShowAll`       | (future use) Show hidden or filtered printers                           |

---

## 🧠 Key Script Breakdown

### 1. Retrieve Printer List

```powershell
net view \\$PrintServer > "$env:TEMP\\netview_temp.txt"
```

- This lists all shared resources on the print server.
- The script filters entries of type `Print` and grabs the share name and comment.

### 2. Parse Output

```powershell
$parts = $line -split '\s{2,}'
$share = $parts[0].Trim()
$comment = if ($parts.Count -gt 2) { $parts[2].Trim() } else { "N/A" }
```

- Grabs the first and third column.
- If the comment is missing or same as the share name, it's shown as `"N/A"`.

### 3. Install Printer via:

```powershell
Start-Process -FilePath "rundll32.exe" -ArgumentList "printui.dll,PrintUIEntry /in /n`"$fullPath`""
```

- Leverages Windows built-in tools to install the printer.

---

## ✅ Example

```powershell
.\NetworkPrinterGuilist2.ps1 -PrintServer "PrintServerFQDN"
```

---

## 🔒 Security

Because this script runs without elevation and uses standard Windows APIs, it is safe for deployment across user environments. However, always validate network security policies before automated installation.

---

## 👨‍💻 Author

Jesus M. Ayala - Sarah Lawrence College.
