# Mac-Arabic123-Fix

[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg?logo=apple)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Language: Arabic](https://img.shields.io/badge/Language-Arabic-red.svg)](#)

A custom Arabic keyboard layout (PC Layout) for macOS that types standard Arabic/Western digits (`123`) instead of Eastern Arabic/Indian digits (`١٢٣`).

*Arabic version: [README_Arabic.md](README_Arabic.md)*

---

## Developer

| | |
|---|---|
| **Name** | Muhammad El-Shaikh |
| **GitHub** | [github.com/ElShaikh1945](https://github.com/ElShaikh1945) |
| **Email** | [Muhammad.Al-Shaikh@outlook.com](mailto:Muhammad.Al-Shaikh@outlook.com) |

---

## Installation Methods

> [!IMPORTANT]
> **Automatic Activation:** The double-click installer below will automatically copy the layout files, enable the keyboard source in macOS settings, and select/switch to it. No manual setup is needed!
> 
> **If the layout does not work immediately:** You may need to restart your Mac to clear the macOS keyboard layout cache.

### 1. Automated Installation via Double-Click (Recommended)
To make installation seamless, a single double-clickable installer script is provided:

* **File:** `install.command`
* **Description:** Once opened, it will ask you for your preferred language and then let you choose between:
  1. **Personal Installation:** Installs the layout under your user directory (`~/Library/Keyboard Layouts`). Safe, easy, and requires no administrator password.
  2. **System-wide Installation:** Installs the layout for all users and the login screen (`/Library/Keyboard Layouts`). Requires your administrator password.

#### Steps to Run:
1. Double-click the `install.command` file in the folder.
   *(Note: If macOS displays a Gatekeeper warning because the files were downloaded from the internet, right-click the file and choose **Open**, or go to **System Settings > Privacy & Security** and allow it to run).*
2. A Terminal window will open automatically. Follow the simple prompts to choose your language and installation type.
3. Once the success message appears, you can safely close the Terminal window.

---

### 2. Using the DMG Installer
1. Open the `Arabic - PC - 123.dmg` file included in the repository.
2. Run the **Keyboard Installer** app inside it.
3. Drag and drop the keyboard layout file onto the installer window.
4. Select **Install for current user**.
5. Manually activate the keyboard layout (see the Activation section below) and restart your Mac.

---

### 3. Manual Installation
1. Copy the `Arabic - 123 - PC.bundle` directory (which contains both the custom icon and the layout mapping).
2. Paste it into the following directory:
   `~/Library/Keyboard Layouts`
   *(Or `/Library/Keyboard Layouts` for system-wide installation).*
3. Follow the manual activation steps below and restart your Mac.

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
