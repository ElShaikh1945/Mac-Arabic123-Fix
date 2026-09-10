import Carbon
import Foundation

// ============================================================
// Mac-Arabic123-Fix v1.0.1
// Developed by Muhammad El-Shaikh
// GitHub:  github.com/ElShaikh1945
// Email:   Muhammad.Al-Shaikh@outlook.com
// Copyright © 2026 Muhammad El-Shaikh. All rights reserved.
// ============================================================

let targetID = "org.sil.ukelele.keyboardlayout.arabic123pc.arabic-123-pc"

// MARK: - Helper Functions

/// Get all input sources from macOS
func getAllInputSources() -> [TISInputSource] {
    guard let sources = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else {
        return []
    }
    return sources
}

/// Get the string value of a TIS property
func getProperty(_ source: TISInputSource, _ key: CFString) -> String? {
    guard let cfValue = TISGetInputSourceProperty(source, key) else { return nil }
    return Unmanaged<AnyObject>.fromOpaque(cfValue).takeUnretainedValue() as? String
}

/// Check if an input source is an Arabic keyboard layout
func isArabicKeyboard(_ source: TISInputSource) -> Bool {
    guard let category = getProperty(source, kTISPropertyInputSourceCategory) else { return false }
    guard category == (kTISCategoryKeyboardInputSource as String) else { return false }
    
    guard let sourceType = getProperty(source, kTISPropertyInputSourceType) else { return false }
    guard sourceType == (kTISTypeKeyboardLayout as String) else { return false }
    
    guard let sourceID = getProperty(source, kTISPropertyInputSourceID) else { return false }
    if sourceID == targetID || sourceID.contains("arabic123pc") {
        return false
    }

    let lowerID = sourceID.lowercased()
    if lowerID.contains("syriac") || lowerID.contains("mandaic") {
        return false
    }

    if lowerID.contains("arabic") {
        return true
    }

    if let name = getProperty(source, kTISPropertyLocalizedName)?.lowercased(),
       name.contains("arabic") || name.contains("عربي") {
        return true
    }

    if let langsVal = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages) {
        let langs = Unmanaged<AnyObject>.fromOpaque(langsVal).takeUnretainedValue() as? [String]
        if let primary = langs?.first {
            if primary == "ar" || primary.hasPrefix("ar-") || primary.hasPrefix("ar_") {
                return true
            }
        }
    }

    return false
}

/// Check if an input source is currently enabled
func isEnabled(_ source: TISInputSource) -> Bool {
    guard let cfValue = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsEnabled) else { return false }
    return Unmanaged<AnyObject>.fromOpaque(cfValue).takeUnretainedValue() as? Bool ?? false
}

// MARK: - Command Handlers

/// Default: Enable and select the custom keyboard layout
func enableAndSelect() {
    let homeBundle = NSString(string: "~/Library/Keyboard Layouts/Arabic - 123 - PC.bundle").expandingTildeInPath
    let sysBundle = "/Library/Keyboard Layouts/Arabic - 123 - PC.bundle"
    if FileManager.default.fileExists(atPath: homeBundle) {
        TISRegisterInputSource(URL(fileURLWithPath: homeBundle) as CFURL)
    }
    if FileManager.default.fileExists(atPath: sysBundle) {
        TISRegisterInputSource(URL(fileURLWithPath: sysBundle) as CFURL)
    }

    let sources = getAllInputSources()
    
    var foundSource: TISInputSource? = nil
    for source in sources {
        let sid = getProperty(source, kTISPropertyInputSourceID) ?? ""
        let name = getProperty(source, kTISPropertyLocalizedName) ?? ""
        if sid == targetID || sid.contains("arabic123pc") || name == "Arabic - 123 - PC" || name == "عربي - 123 - PC" {
            foundSource = source
            break
        }
    }
    
    guard let source = foundSource else {
        print("Swift Error: Could not find keyboard layout '\(targetID)' in the installed layouts list.")
        print("Note: Please make sure the bundle has been copied correctly and the keyboard cache has refreshed.")
        exit(1)
    }
    
    print("Found custom keyboard layout: \(targetID)")
    
    // Enable the input source in the system settings
    let enableStatus = TISEnableInputSource(source)
    if enableStatus == noErr {
        print("Successfully enabled keyboard layout in System Settings.")
    } else {
        print("Warning: Failed to enable keyboard layout (Status Code: \(enableStatus)).")
    }
    
    // Select (activate) the input source as the active keyboard
    let selectStatus = TISSelectInputSource(source)
    if selectStatus == noErr {
        print("Successfully activated and switched to: Arabic - 123 - PC.")
    } else {
        print("Warning: Failed to switch to the new keyboard layout (Status Code: \(selectStatus)).")
    }
    
    exit(0)
}

/// List all enabled Arabic keyboard layouts (excluding our custom one)
func listArabic() {
    let sources = getAllInputSources()
    var found = false
    
    for source in sources {
        guard isArabicKeyboard(source) else { continue }
        guard isEnabled(source) else { continue }
        
        let sourceID = getProperty(source, kTISPropertyInputSourceID) ?? "unknown"
        let sourceName = getProperty(source, kTISPropertyLocalizedName) ?? sourceID
        
        print("\(sourceID)|\(sourceName)")
        found = true
    }
    
    if !found {
        // No Arabic keyboards found (other than ours), output nothing
        exit(0)
    }
    
    exit(0)
}

/// Disable specific input sources by their IDs (comma-separated)
func disableByIDs(_ idsString: String) {
    let idsToDisable = idsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    let sources = getAllInputSources()
    var disabledCount = 0
    
    for source in sources {
        guard let sourceID = getProperty(source, kTISPropertyInputSourceID) else { continue }
        
        if idsToDisable.contains(sourceID) {
            let status = TISDisableInputSource(source)
            if status == noErr {
                let name = getProperty(source, kTISPropertyLocalizedName) ?? sourceID
                print("Disabled: \(name) (\(sourceID))")
                disabledCount += 1
            } else {
                print("Warning: Failed to disable \(sourceID) (Status Code: \(status)).")
            }
        }
    }
    
    print("Total disabled: \(disabledCount)")
    exit(0)
}

/// Disable all Arabic keyboards except our custom one
func cleanOldArabic() {
    let sources = getAllInputSources()
    var disabledCount = 0
    
    for source in sources {
        guard isArabicKeyboard(source) else { continue }
        guard isEnabled(source) else { continue }
        
        let sourceID = getProperty(source, kTISPropertyInputSourceID) ?? "unknown"
        let name = getProperty(source, kTISPropertyLocalizedName) ?? sourceID
        
        let status = TISDisableInputSource(source)
        if status == noErr {
            print("Disabled: \(name) (\(sourceID))")
            disabledCount += 1
        } else {
            print("Warning: Failed to disable \(sourceID) (Status Code: \(status)).")
        }
    }
    
    print("Total disabled: \(disabledCount)")
    exit(0)
}

/// Check if the custom keyboard layout is already installed/present in the system
func checkInstalled() {
    let sources = getAllInputSources()
    for source in sources {
        let sid = getProperty(source, kTISPropertyInputSourceID) ?? ""
        let name = getProperty(source, kTISPropertyLocalizedName) ?? ""
        if sid == targetID || name == "Arabic - 123 - PC" || name == "عربي - 123 - PC" {
            let enabled = isEnabled(source)
            print("INSTALLED|\(sid)|\(enabled ? "ENABLED" : "DISABLED")")
            exit(0)
        }
    }
    print("NOT_INSTALLED")
    exit(1)
}

/// List all installed Arabic keyboard layouts (enabled or disabled)
func listAllArabic() {
    let sources = getAllInputSources()
    for source in sources {
        guard isArabicKeyboard(source) else { continue }
        let sourceID = getProperty(source, kTISPropertyInputSourceID) ?? "unknown"
        let sourceName = getProperty(source, kTISPropertyLocalizedName) ?? sourceID
        let en = isEnabled(source)
        print("\(sourceID)|\(sourceName)|\(en ? "ENABLED" : "DISABLED")")
    }
    exit(0)
}

/// Enable and select a specific input source by ID
func enableByID(_ targetIDToEnable: String) {
    let cleanID = targetIDToEnable.trimmingCharacters(in: .whitespaces)
    let sources = getAllInputSources()
    for source in sources {
        guard let sourceID = getProperty(source, kTISPropertyInputSourceID), sourceID == cleanID else { continue }
        TISEnableInputSource(source)
        TISSelectInputSource(source)
        let name = getProperty(source, kTISPropertyLocalizedName) ?? cleanID
        print("Successfully activated: \(name)")
        exit(0)
    }
    print("Error: Input source '\(cleanID)' not found.")
    exit(1)
}

// MARK: - Main Entry Point

let args = CommandLine.arguments

if args.count > 1 {
    switch args[1] {
    case "--check-installed":
        checkInstalled()
    case "--list-arabic":
        listArabic()
    case "--list-all-arabic":
        listAllArabic()
    case "--enable-id":
        guard args.count > 2 else {
            print("Error: --enable-id requires an input source ID.")
            exit(1)
        }
        enableByID(args[2])
    case "--disable-ids":
        guard args.count > 2 else {
            print("Error: --disable-ids requires a comma-separated list of input source IDs.")
            print("Usage: enable_layout --disable-ids \"com.apple.keylayout.Arabic,com.apple.keylayout.Arabic-PC\"")
            exit(1)
        }
        disableByIDs(args[2])
    case "--clean-old-arabic":
        cleanOldArabic()
    default:
        print("Unknown option: \(args[1])")
        print("Usage:")
        print("  enable_layout                          Enable and select Arabic-123-PC")
        print("  enable_layout --check-installed        Check if Arabic-123-PC is installed")
        print("  enable_layout --list-arabic            List enabled Arabic keyboards")
        print("  enable_layout --list-all-arabic        List all installed Arabic keyboards")
        print("  enable_layout --enable-id \"ID\"         Enable and select a keyboard by ID")
        print("  enable_layout --disable-ids \"ID1,ID2\"  Disable specific keyboards by ID")
        print("  enable_layout --clean-old-arabic       Disable all Arabic keyboards except Arabic-123-PC")
        exit(1)
    }
} else {
    enableAndSelect()
}
