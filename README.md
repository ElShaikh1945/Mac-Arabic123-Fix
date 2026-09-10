# Mac-Arabic123-Fix

[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg?logo=apple)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Language: Arabic](https://img.shields.io/badge/Language-Arabic-red.svg)](#)
[![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-green.svg)](#)
[![Downloads](https://img.shields.io/github/downloads/ElShaikh1945/Mac-Arabic123-Fix/total.svg?color=brightgreen)](https://github.com/ElShaikh1945/Mac-Arabic123-Fix/releases)

A custom Arabic keyboard layout (PC Layout) for macOS that types standard Arabic/Western digits (`123`) instead of Eastern Arabic/Indian digits (`١٢٣`). Supports **both the top number row and the Numpad**.

*النسخة العربية: [README_Arabic.md](README_Arabic.md)*

---

## Developer

| | |
|---|---|
| **Name** | Muhammad El-Shaikh |
| **GitHub** | [github.com/ElShaikh1945](https://github.com/ElShaikh1945) |
| **Email** | [Muhammad.Al-Shaikh@outlook.com](mailto:Muhammad.Al-Shaikh@outlook.com) |

---

## Features

- ✅ **Standard Digits (123)** on both top row keys and Numpad keys.
- ✅ **Universal Binary**: Native support for both Apple Silicon (M1/M2/M3/M4) and Intel (`x86_64`) Macs.
- ✅ **Duplicate Prevention & Overwrite Confirmation**: Detects existing installations and offers a clean overwrite to prevent duplicate entries in macOS System Settings.
- ✅ **Bilingual Localization**: Native Arabic (`ar.lproj`) and English (`en.lproj`) bundle localization.
- ✅ **Dual-Mode High-Contrast Icon**: Redesigned crisp badge ensuring crystal-clear visibility in Dark Mode, Light Mode, and the macOS blue Switcher HUD (Cmd+Space / Globe key).
- ✅ **Dedicated Clean Uninstaller (`uninstall.command`)**: Interactive one-click complete removal of the layout and automatic cache cleanup.
- ✅ **Interactive Terminal UI** with blue-highlighted arrow-key navigation menus (↑/↓ + Enter).
- ✅ **Strict Language Mode**: After choosing Arabic or English, all installer text strictly follows your choice — no mixed languages.
- ✅ **Post-Install Verification Guide** with sample test phrases to confirm the layout works correctly.
- ✅ **Multi-Select Checklist** to selectively remove old Arabic keyboard layouts after installation.
- ✅ **Automatic Activation**: The installer copies, enables, and switches to the new layout automatically.
- ✅ **Smart Fallback**: If system-wide installation fails, the installer offers personal installation as an alternative.

---

## Installation Methods

> [!TIP]
> **First-Time Launch on macOS:** If macOS shows a security warning ("unidentified developer"), use one of these quick methods:
> 1. **One-line Terminal command (Quickest):** Run inside the folder:
>    ```bash
>    xattr -cr . && ./install.command
>    ```
> 2. **Right-click** the file → select **Open** → click **Open** in the dialog.
> 3. Go to **System Settings > Privacy & Security** → click **Open Anyway**.

> [!NOTE]
> **FileVault & Startup Login Screen:** If your Mac has FileVault encryption enabled, macOS cannot access user-level layouts before you log in after a cold restart. Choose **System-wide installation** if you need this layout available on the startup login screen.

> [!IMPORTANT]
> **Automatic Activation:** The double-click installer below will automatically copy the layout files, enable the keyboard source in macOS settings, and select/switch to it. No manual setup is needed!
>
> **If the layout does not work immediately:** You may need to restart your Mac to clear the macOS keyboard layout cache.

### 1. Automated Installation via Double-Click (Recommended)
To make installation seamless, a single double-clickable installer script is provided:

* **File:** `install.command`
* **Description:** Once opened, it will:
  1. Display an interactive language selection menu (Arabic / English) with blue-highlighted arrow-key navigation.
  2. Let you choose between Personal or System-wide installation using the same interactive menu.
  3. Install the keyboard layout automatically with a visual progress bar.
  4. Display a verification guide with sample test phrases.
  5. Offer a multi-select checklist to remove old Arabic keyboard layouts.

#### Steps to Run:
1. Download the latest release: [**Mac-Arabic123-Fix-v1.0.1.zip**](https://github.com/ElShaikh1945/Mac-Arabic123-Fix/releases/latest) and extract it.
2. Double-click the `install.command` file in the folder.
3. A Terminal window will open automatically. Use the **↑/↓ arrow keys** and **Enter** to navigate the interactive menus.
4. Once the success message appears, follow the verification guide to test the layout.
5. Optionally select old Arabic keyboards to remove.
6. You can safely close the Terminal window.

---

### 2. Manual Installation
1. Copy the `Arabic - 123 - PC.bundle` directory (which contains both the custom icon and the layout mapping).
2. Paste it into the following directory:
   `~/Library/Keyboard Layouts`
   *(Or `/Library/Keyboard Layouts` for system-wide installation).*
3. Follow the manual activation steps below and restart your Mac.

---

## Interactive Installer Features

### Arrow-Key Navigation Menus
All choices in the installer use interactive menus with:
- **Blue highlight** on the selected option.
- **↑/↓ arrow keys** to navigate between options.
- **Enter** to confirm your selection.
- Optional **1/2** number keys for quick selection.

### Multi-Select Checklist (Old Layout Cleanup)
After installation, the installer detects existing Arabic keyboard layouts and presents a checklist:
- **↑/↓** to navigate between keyboards.
- **Space** to toggle `[ ]` / `[✓]` selection.
- **Enter** to confirm and remove selected layouts.
- Selecting nothing and pressing Enter keeps all layouts unchanged.

### Post-Install Verification Guide
The installer displays a testing guide with:
1. **Digit test** (top row + Numpad): Type `1234567890`.
2. **PC key positions test**: Verify keys like `ذ`, `ط`, `ك`.
3. **Sample test phrase**: `"Keyboard Test 2026: No. 123 - ذ ط ك - 100%"`

---

## Uninstallation
To completely remove the keyboard layout from your Mac:

1. Double-click **`uninstall.command`**.
2. Select your language and confirm uninstallation.
3. Optionally, select an alternative Arabic keyboard layout to activate automatically before removal.
4. The script will automatically disable the input source, delete all layout bundles, and refresh the macOS keyboard cache.

---

## Manual Activation (Fallback)
If the automated installer did not automatically select the keyboard layout, you can activate it manually:

1. Go to **System Settings > Keyboard > Input Sources**.
2. If an older version of 'Arabic - 123 - PC' is active, remove it by selecting it and clicking the minus **(-)** button.
3. Click the plus **(+)** button at the bottom.
4. Select **Others** from the left sidebar.
5. Select **Arabic - 123 - PC** and click **Add**.

---

## License
This project is licensed under the [MIT License](LICENSE).

Copyright © 2026 Muhammad El-Shaikh. All rights reserved.
