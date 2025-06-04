# NetworkSharedPrinterBasic (No Admin Required)

## 🖨️ Overview

This PowerShell script provides a graphical interface (GUI) that allows users to view, select, and install shared network printers from a remote print server. It is specifically designed to work **without requiring administrative privileges**. The script dynamically queries available printers via `net view`, extracts share names and comments, and presents them in a list.

---

## 📦 Features

- ✅ No admin rights required
- 🔍 Dynamically retrieves printer shares from a remote SMB print server
- 🗒️ Displays printer share names and descriptive comments (location/model)
- 🪟 GUI interface with multi-column layout and responsive design
- 🔘 "Install Selected" and "Exit" buttons for simple user control
- 🖨️ Uses Windows `printui.dll` to install printers
- 🧑‍💻 Supports non-admin installs via Point and Print
- 🔧 Fallback static list when live lookup fails
- 🏃 CLI parameters for scripting or automated deployment
- 📋 Full debug logging for troubleshooting
- 📐 Anchored and resizable layout (modern WinForms UI)

---

## 🔧 Requirements

- Windows OS (PowerShell 5.1+)
- Network access to the remote print server
- Printers shared via `net view \\PrintServer`

---

## 🚀 Usage

### 🔹 Basic Run (Interactive GUI)

```powershell
.\NetworkPrinterGui.ps1
```

- Uses the default server (if defined inside the script)
- Launches a GUI to view and select printers
- Installs selected printers via built-in Windows tools

---

### 🔹 Use with Specific Print Server

```powershell
.\NetworkPrinterGui.ps1 -PrintServer "vm-printq.admin.slc.edu"
```

- Overrides the default and fetches printers from the specified host

---

### 🔹 Silent Install with Auto Mode

```powershell
.\NetworkPrinterGui.ps1 -PrintServer "vm-printq.admin.slc.edu" -Silent -AutoInstall
```

- Suppresses GUI
- Installs **all** discovered printers automatically
- Use this for mass deployments or login scripts

---

## ⚙️ Parameters

| Parameter         | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `-PrintServer`    | Set the print server host (e.g., `vm-printq.admin.slc.edu`)                |
| `-Silent`         | Run with no GUI. **Only meaningful if combined with `-AutoInstall`**       |
| `-AutoInstall`    | Automatically install all discovered printers. Requires `-Silent`          |

---

## 🧠 Script Breakdown

### 🔸 Step 1: Discover Printers

```powershell
net view \\$PrintServer > "$env:TEMP\\netview_temp.txt"
```

- Extracts all shared resources
- Filters for those marked as `Print` type

### 🔸 Step 2: Parse Printer Data

```powershell
$parts = $line -split '\s{2,}'
$share = $parts[0].Trim()
$comment = if ($parts.Count -gt 2) { $parts[2].Trim() } else { "N/A" }
```

- Comment used as location or description
- If missing, `"N/A"` is shown in the location field

### 🔸 Step 3: Install Selected Printers

```powershell
Start-Process "rundll32.exe" -ArgumentList "printui.dll,PrintUIEntry /in /n`"$fullUNC`""
```

- Uses built-in tools — no need for `Get-Printer` or admin rights

---

## 🧪 Example

```powershell
.\NetworkPrinterGui.ps1 -PrintServer "vm-printq.admin.slc.edu"
```

---

## 🛡️ Security Notes

- No elevation is needed
- Uses standard Windows tools and APIs
- Does not modify system configuration or registry
- Safe for use in domain or lab environments with Point and Print enabled

---

## 👨🏾‍💻 Author

**Jesus M. Ayala**  
ITS Help Desk, Sarah Lawrence College  
🔧 Built for network-wide deployment and end-user self-service