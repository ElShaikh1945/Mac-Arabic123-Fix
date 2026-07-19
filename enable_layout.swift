import Carbon
import Foundation

// Get all keyboard layouts, including those that are installed but not yet enabled.
guard let sources = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else {
    print("Swift Error: Could not retrieve input sources from macOS HIToolbox.")
    exit(1)
}

let targetID = "org.sil.ukelele.keyboardlayout.arabic123pc.arabic-123-pc"
var foundSource: TISInputSource? = nil

for source in sources {
    let cfID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
    if cfID == nil { continue }
    let sourceID = Unmanaged<AnyObject>.fromOpaque(cfID!).takeUnretainedValue() as? String ?? ""
    
    if sourceID == targetID {
        foundSource = source
        break
    }
}

if let source = foundSource {
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
} else {
    print("Swift Error: Could not find keyboard layout '\(targetID)' in the installed layouts list.")
    print("Note: Please make sure the bundle has been copied correctly and the keyboard cache has refreshed.")
    exit(1)
}
