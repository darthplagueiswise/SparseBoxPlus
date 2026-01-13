import SwiftUI
import UniformTypeIdentifiers
import PartyUI

struct TweaksView: View {
    @State private var mbdb: Backup?
    @State private var viewShouldUpdate = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var appData: AppData
    
    @AppStorage("BookassetdContainerUUID") var bookassetdUUID: String?
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "Software-Oriented Features", icon: "gearshape")) {
                    ListToggleItem(text: "Enable Dynamic Island", icon: "platter.filled.top.iphone", minSupportedVersion: 26.0, isOn: bindingForMGKeys(["YlEtTtHlNesRBMal1CqRaA"]))
                    ListToggleItem(text: "Enable Always On Display", icon: "sun.max", minSupportedVersion: 18.0, isOn: bindingForMGKeys(["j8/Omm6s1lsmTDFsXjsBfA", "2OOJf1VhaM7NxfRok3HbWQ"]))
                    ListToggleItem(text: "Enable Charge Limit", icon: "battery.100.bolt", minSupportedVersion: 17.0, isOn: bindingForMGKeys(["37NVydb//GP/GrhuTN+exg"]))
                    ListToggleItem(text: "Enable Boot Chime", icon: "speaker.wave.3", isOn: bindingForMGKeys(["QHxt+hGLaBPbQJbXiUJX3w"]))
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
                
                Section(header: HeaderLabel(text: "Hardware-Oriented Features", icon: "iphone")) {
                    ListToggleItem(text: "Enable Camera Control", icon: "camera.shutter.button", minSupportedVersion: 18.0, isOn: bindingForMGKeys(["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"]))
                    ListToggleItem(text: "Enable Action Button", icon: "button.vertical.left.press", minSupportedVersion: 17.0, isOn: bindingForMGKeys(["cT44WE1EohiwRzhsZ8xEsw"]))
                    ListToggleItem(text: "Enable Crash Detection", icon: "car", isOn: bindingForMGKeys(["HCzWusHQwZDea6nNhaKndw"]))
                    if UIDevice._hasHomeButton() {
                        ListToggleItem(text: "Enable Tap to Wake", icon: "hand.tap", isOn: bindingForMGKeys(["yZf3GTRMGTuwSV/lD7Cagw"]))
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
                
                Section(header: HeaderLabel(text: "Eligibility", icon: "checklist")) {
                    ListToggleItem(text: "Enable SRD UI", icon: "terminal", minSupportedVersion: 26.0, isOn: bindingForMGKeys(["XYlJKKkj2hztRP1NWWnhlw"]))
                    ListToggleItem(text: "Disable Region Restrictions", icon: "globe", isOn: bindingForRegionRestriction())
                    ListToggleItem(text: "Enable Apple Intelligence", icon: "apple.intelligence", minSupportedVersion: 18.1, isOn: bindingForAppleIntelligence())
                    HStack {
                        Picker("Model Spoofing", selection:$appData.productType) {
                            Text("Default").tag(machineName())
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                Text("iPad Pro 11 inch 5th Gen").tag("iPad16,3")
                            } else {
                                Text("iPhone 15 Pro Max").tag("iPhone16,2")
                                Text("iPhone 16 Pro Max").tag("iPhone17,2")
                            }
                        }
                        .modifier(GlassyListRowBackground())
                        Button(action: {
                            Alertinator.shared.alert(title: "Device Spoofing Info", body: "Only spoof your device model if you want to download Apple Intelligence. This may break Face ID. If you decide to unspoof and want to keep Apple Intelligence, do NOT re-enter the Apple Intelligence & Siri menu in Settings.")
                        }) {
                            Image(systemName: "info.circle")
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(GlassyButtonStyle(useFullWidth: false))
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
                
                Section(header: HeaderLabel(text: "iPadOS Features", icon: "ipad")) {
                    let cacheExtra = appData.mobileGestalt["CacheExtra"] as? NSMutableDictionary
                    
                    ListToggleItem(text: "Allow Installing iPadOS Apps", icon: "plus.app", isOn: bindingForMGKeys(["9MZ5AdH43csAUajl/dU+IQ"], type: [Int].self, defaultValue: [1], enableValue: [1, 2]))
                    ListToggleItem(text: "Enable Apple Pencil Settings", icon: "pencil", isOn: bindingForMGKeys(["yhHcB0iH0d1XzPO/CFd3ow"]))
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        ListToggleItem(text: "Enable Stage Manager", icon: "squares.leading.rectangle", isOn: bindingForMGKeys(["qeaj75wk3HF4DwQ8qbIi7g"]))
                    }
                    HStack {
                        ListToggleItem(text: "Enable iPadOS UI", icon: "ipad", isOn: bindingForTrollPad())
                            .disabled(cacheExtra?["+3Uf0Pm5F8Xy7Onyvko0vA"] as? String != "iPhone")
                        Button(action: {
                            Alertinator.shared.alert(title: "Warning!", body: "This changes the UI idiom to iPadOS, giving you multitasking features and other iPadOS UI elements. Gives the same capbilities as TrollPad, but may cause issues.\n\nWARNING: Please do not turn off \"Show Dock In Stage Manager\" or your device will BOOTLOOP when rotating to landscape. Also, do NOT use this tweak with an alphanumeric passcode!")
                        }) {
                            Image(systemName: "exclamationmark.triangle")
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(GlassyButtonStyle(color: .red, useFullWidth: false))
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
                
                Section(header: HeaderLabel(text: "Internal", icon: "ant")) {
                    ListToggleItem(text: "Enable Internal Storage", icon: "externaldrive", isOn: bindingForMGKeys(["LBJfwOEzExRxzlAnSuI7eg"]))
                    ListToggleItem(text: "Enable Internal Features", icon: "gearshape", isOn: bindingForInternalStuff())
                    ListToggleItem(text: "Metal HUD in All Apps", icon: "terminal", isOn: bindingForMGKeys(["EqrsVvjcYDdxHBiQmGhAWw"]))
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
            }
            .listStyle(.plain)
            .navigationTitle("Tweaks")
            .onAppear {
                if appData.initError != nil {
                    Alertinator.shared.alert(title: "Error!", body: "\(appData.initError ?? "something happened lol")")
                    return
                }
                
                if let cacheExtra = appData.mobileGestalt["CacheExtra"] as? NSMutableDictionary {
                    appData.productType = cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] as! String
                }
            }
            .onChange(of: scenePhase) { newPhase in
                // keep HTTP server alive in the background for a while
                if scenePhase == .inactive {
                    Utils.bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                        // This executes when time is about to run out
                        UIApplication.shared.endBackgroundTask(Utils.bgTask)
                        Utils.bgTask = .invalid
                    })
                    if Utils.bgTask == .invalid {
                        print("Failed to start background task")
                        return
                    }
                } else if scenePhase == .active {
                    if Utils.bgTask != .invalid {
                        UIApplication.shared.endBackgroundTask(Utils.bgTask)
                        Utils.bgTask = .invalid
                    }
                }
            }
        }
        .modifier(PrimaryViewModifier())
    }
    
    func bindingForAppleIntelligence() -> Binding<Bool> {
        guard let cacheExtra = appData.mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        let key = "A62OafQ85EJAiiqKn4agtg"
        return Binding(
            get: {
                _ = viewShouldUpdate
                if let value = cacheExtra[key] as? Int? {
                    return value == 1
                }
                return false
            },
            set: { enabled in
                if enabled {
                    appData.eligibilityData = try! Data(contentsOf: Bundle.main.url(forResource: "eligibility", withExtension: "plist")!)
                    appData.featureFlagsData = try! Data(contentsOf: Bundle.main.url(forResource: "FeatureFlags_Global", withExtension: "plist")!)
                    cacheExtra[key] = 1
                } else {
                    appData.featureFlagsData = try! PropertyListSerialization.data(fromPropertyList: [:], format: .xml, options: 0)
                    appData.eligibilityData = appData.featureFlagsData
                    // just remove the key as it will be pulled from device tree if missing
                    cacheExtra.removeObject(forKey: key)
                }
                DispatchQueue.main.async {
                    viewShouldUpdate.toggle()
                }
            }
        )
    }

    func bindingForRegionRestriction() -> Binding<Bool> {
        guard let cacheExtra = appData.mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        return Binding<Bool>(
            get: {
                _ = viewShouldUpdate
                return cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] as? String == "US" &&
                    cacheExtra["zHeENZu+wbg7PUprwNwBWg"] as? String == "LL/A"
            },
            set: { enabled in
                if enabled {
                    cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] = "US"
                    cacheExtra["zHeENZu+wbg7PUprwNwBWg"] = "LL/A"
                } else {
                    cacheExtra.removeObject(forKey: "h63QSdBCiT/z0WU6rdQv6Q")
                    cacheExtra.removeObject(forKey: "zHeENZu+wbg7PUprwNwBWg")
                }
                DispatchQueue.main.async {
                    viewShouldUpdate.toggle()
                }
            }
        )
    }
    
    func bindingForInternalStuff() -> Binding<Bool> {
        // we need to do it via CacheData
        guard let cacheData = appData.mobileGestalt["CacheData"] as? NSMutableData else {
            return State(initialValue: false).projectedValue
        }
        let off_appleInternalInstall = FindCacheDataOffset("EqrsVvjcYDdxHBiQmGhAWw")
        let off_HasInternalSettingsBundle = FindCacheDataOffset("Oji6HRoPi7rH7HPdWVakuw")
        let off_InternalBuild = FindCacheDataOffset("LBJfwOEzExRxzlAnSuI7eg")
        //print("Read value from \(cacheData.mutableBytes.load(fromByteOffset: valueOffset, as: Int.self))")
        
        return Binding(
            get: {
                _ = viewShouldUpdate
                return cacheData.bytes.load(fromByteOffset: off_appleInternalInstall, as: Int.self) == 1
            },
            set: { enabled in
                cacheData.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_appleInternalInstall, as: Int.self)
                cacheData.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_HasInternalSettingsBundle, as: Int.self)
                cacheData.mutableBytes.storeBytes(of: enabled ? 1 : 0, toByteOffset: off_InternalBuild, as: Int.self)
                DispatchQueue.main.async {
                    viewShouldUpdate.toggle()
                }
            }
        )
    }
    
    func bindingForTrollPad() -> Binding<Bool> {
        // We're going to overwrite DeviceClassNumber but we can't do it via CacheExtra, so we need to do it via CacheData instead
        guard let cacheData = appData.mobileGestalt["CacheData"] as? NSMutableData,
              let cacheExtra = appData.mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        let valueOffset = FindCacheDataOffset("mtrAoWJ3gsq+I90ZnQ0vQw")
        //print("Read value from \(cacheData.mutableBytes.load(fromByteOffset: valueOffset, as: Int.self))")
        
        let keys = [
            "uKc7FPnEO++lVhHWHFlGbQ", // ipad
            "mG0AnH/Vy1veoqoLRAIgTA", // MedusaFloatingLiveAppCapability
            "UCG5MkVahJxG1YULbbd5Bg", // MedusaOverlayAppCapability
            "ZYqko/XM5zD3XBfN5RmaXA", // MedusaPinnedAppCapability
            "nVh/gwNpy7Jv1NOk00CMrw", // MedusaPIPCapability,
            "qeaj75wk3HF4DwQ8qbIi7g", // DeviceSupportsEnhancedMultitasking
        ]
        return Binding(
            get: {
                _ = viewShouldUpdate
                if let value = cacheExtra[keys.first!] as? Int? {
                    return value == 1
                }
                return false
            },
            set: { enabled in
                cacheData.mutableBytes.storeBytes(of: enabled ? 3 : 1, toByteOffset: valueOffset, as: Int.self)
                for key in keys {
                    if enabled {
                        cacheExtra[key] = 1
                    } else {
                        // just remove the key as it will be pulled from device tree if missing
                        cacheExtra.removeObject(forKey: key)
                    }
                }
                DispatchQueue.main.async {
                    viewShouldUpdate.toggle()
                }
            }
        )
    }
    
    func bindingForMGKeys<T: Equatable>(_ keys: [String], type: T.Type = Int.self, defaultValue: T? = 0, enableValue: T? = 1) -> Binding<Bool> {
        guard let cacheExtra = appData.mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
            return State(initialValue: false).projectedValue
        }
        return Binding(
            get: {
                _ = viewShouldUpdate
                if let value = cacheExtra[keys.first!] as? T?, let enableValue {
                    return value == enableValue
                }
                return false
            },
            set: { enabled in
                for key in keys {
                    if enabled {
                        cacheExtra[key] = enableValue
                    } else {
                        // just remove the key as it will be pulled from device tree if missing
                        cacheExtra.removeObject(forKey: key)
                    }
                }
                DispatchQueue.main.async {
                    viewShouldUpdate.toggle()
                }
            }
        )
    }
    
    func generateFilesToRestore() -> [FileToRestore] {
        return [
            FileToRestore(from: appData.modMGURL, to: URL(filePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"), owner: 501, group: 501),
            FileToRestore(contents: appData.eligibilityData, to: URL(filePath: "/var/db/eligibilityd/eligibility.plist")),
            FileToRestore(contents: appData.featureFlagsData, to: URL(filePath: "/var/preferences/FeatureFlags/Global.plist")),
        ]
    }
}

#Preview {
    NavigationStack {
        TweaksView()
    }
}
