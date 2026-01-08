import SwiftUI
import UniformTypeIdentifiers
import PartyUI
import DeviceKit

struct MobileGestaltView: View {
    @State private var mbdb: Backup?
    @State private var eligibilityData = Data()
    @State private var featureFlagsData = Data()
    @State private var mobileGestalt: NSMutableDictionary
    @State private var productType = machineName()
    
    @State private var respring = true
    @State private var taskRunning = false
    @State private var initError: String?
    @State private var viewShouldUpdate = false
    
    @State private var showMobileGestaltFileView: Bool = false
    @State private var applicationIcon: String = "checkmark.circle.fill"
    @State private var applicationIconColor: Color = .primary
    @State private var applicationStatus: String = "Ready to Apply"
    @State private var hasShownWelcome: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("BookassetdContainerUUID") private var bookassetdUUID: String?
    
    let device = Device.current
    let origMGURL, modMGURL, featFlagsURL: URL
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HeaderLabel(text: "MobileGesalt Tweaks", icon: "sparkle")) {
                    VStack(alignment: .leading) {
                        HStack {
                            if applicationIcon == "showMeProgressPlease" {
                                ProgressView()
                                    .offset(y: 1)
                            } else {
                                Image(systemName: applicationIcon)
                                    .foregroundStyle(applicationIconColor)
                            }
                            Text(applicationStatus)
                                .fontWeight(.semibold)
                        }
                        Text("HTTP Server Port: \(String(Utils.port))")
                        TerminalContainer(content: VStack {
                            LogView()
                        })
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .modifier(DynamicGlassEffect(shape: AnyShape(.rect(cornerRadius: 24)), useBackground: false))
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
                
                Section(header: HeaderLabel(text: "Application Settings", icon: "gear")) {
                    HStack {
                        TextField("bookassetsd UUID", text: Binding(
                            get: { bookassetdUUID ?? "" },
                            set: { bookassetdUUID = $0.isEmpty ? nil : $0 }
                        ))
                        .textFieldStyle(GlassyTextFieldStyle(isDisabled: bookassetdUUID == nil))
                        Button(action: {
                            bookassetdUUID = nil
                        }) {
                            Image(systemName: "xmark")
                                .frame(width: 18, height: 24)
                        }
                        .buttonStyle(GlassyButtonStyle(isDisabled: bookassetdUUID == nil, color: .red, useFullWidth: false))
                    }
                    .disabled(bookassetdUUID == nil)
                    Toggle("Respring After Finish Restoring", isOn: $respring)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.dropdownRowInsets)
                
                Section(header: HeaderLabel(text: "Software-Oriented Features", icon: "gearshape")) {
                    ListToggleItem(text: "Enable Dynamic Island", icon: "platter.filled.top.iphone", minSupportedVersion: 17.4, isOn: bindingForMGKeys(["YlEtTtHlNesRBMal1CqRaA"]))
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
                        Picker("Model Spoofing", selection:$productType) {
                            Text("Default").tag(MobileGestaltView.machineName())
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
                    let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary
                    
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
            .navigationTitle("MobileGestalt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showMobileGestaltFileView.toggle()
                    }) {
                        Image(systemName: "doc")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button(action: {
                        saveProductType()
                        try! mobileGestalt.write(to: modMGURL)
                        DispatchQueue.global(qos: .background).async {
                            Task {
                                do {
                                    try await performApplyMobileGestalt()
                                } catch {
                                    await MainActor.run {
                                        Alertinator.shared.alert(title: "Failed to Apply!", body: "Error: \(error)")
                                    }
                                }
                            }
                        }
                    }) {
                        ButtonLabel(text: "Apply Tweaks", icon: "checkmark")
                    }
                    .buttonStyle(GlassyButtonStyle(color: .green))
                    
                    HStack {
                        Button(action: {
                            try! FileManager.default.removeItem(at: modMGURL)
                            try! FileManager.default.copyItem(at: origMGURL, to: modMGURL)
                            mobileGestalt = try! NSMutableDictionary(contentsOf: modMGURL, error: ())
                            DispatchQueue.global(qos: .background).async {
                                Task {
                                    do {
                                        try await performApplyMobileGestalt()
                                    } catch {
                                        await MainActor.run {
                                            Alertinator.shared.alert(title: "Failed to Revert!", body: "Error: \(error)")
                                        }
                                    }
                                }
                            }
                        }) {
                            ButtonLabel(text: "Revert", icon: "xmark")
                        }
                        .buttonStyle(GlassyButtonStyle(color: .red))
                        Button(action: {
                            respringDevice()
                        }) {
                            ButtonLabel(text: "Respring", icon: "gobackward")
                        }
                        .buttonStyle(GlassyButtonStyle(color: .orange))
                    }
                }
                .modifier(OverlayBackground())
            }
            .onAppear {
                if !hasShownWelcome {
                    print("[*] Welcome to SparseBox+!\n[*] Running on \(device.systemName!) \(device.systemVersion!), \(device.description)\n[!] WARNING: This tool has the potential to break or bootloop your device! It's highly recommended to create a backup before usage.\n[*] wait, this ui seems familiar...")
                    hasShownWelcome = true
                }
                
                if initError != nil {
                    Alertinator.shared.alert(title: "Error!", body: "\(initError ?? "something happened lol")")
                    return
                }
                
                if let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary {
                    productType = cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] as! String
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
            .sheet(isPresented: $showMobileGestaltFileView) {
                MobileGestaltViewer() {
                    // fix this please: not surprised this didn't work how i hoped it would
                    Section(header: HeaderLabel(text: "Actions", icon: "wrench.and.screwdriver.fill")) {
                        VStack(spacing: 8) {
                            Button(action: {
                                saveProductType()
                                try! mobileGestalt.write(to: modMGURL)
                                presentShareSheet(with: modMGURL)
                            }) {
                                ButtonLabel(text: "Export Modified MobileGestalt", icon: "doc.badge.gearshape")
                            }
                            .buttonStyle(GlassyButtonStyle())
                            
                            Button(action: {
                                presentShareSheet(with: origMGURL)
                            }) {
                                ButtonLabel(text: "Export Original MobileGestalt", icon: "arrow.up.doc")
                            }
                            .buttonStyle(GlassyButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    init() {
        let documentsDirectory = URL.documentsDirectory
        featFlagsURL = documentsDirectory.appendingPathComponent("FeatureFlags.plist", conformingTo: .data)
        origMGURL = documentsDirectory.appendingPathComponent("OriginalMobileGestalt.plist", conformingTo: .data)
        modMGURL = documentsDirectory.appendingPathComponent("ModifiedMobileGestalt.plist", conformingTo: .data)
        
        do {
            if !FileManager.default.fileExists(atPath: origMGURL.path) {
                let url = URL(filePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
                try FileManager.default.copyItem(at: url, to: origMGURL)
            }
            chmod(origMGURL.path, 0o644)
            
            if !FileManager.default.fileExists(atPath: modMGURL.path) {
                try FileManager.default.copyItem(at: origMGURL, to: modMGURL)
            }
            chmod(modMGURL.path, 0o644)
            
            _mobileGestalt = State(initialValue: try NSMutableDictionary(contentsOf: modMGURL, error: ()))
        } catch {
            _mobileGestalt = State(initialValue: [:])
            _initError = State(initialValue: "Failed to copy MobileGestalt: \(error)")
            taskRunning = true
        }
    }
    
    func bindingForAppleIntelligence() -> Binding<Bool> {
        guard let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
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
                    eligibilityData = try! Data(contentsOf: Bundle.main.url(forResource: "eligibility", withExtension: "plist")!)
                    featureFlagsData = try! Data(contentsOf: Bundle.main.url(forResource: "FeatureFlags_Global", withExtension: "plist")!)
                    cacheExtra[key] = 1
                } else {
                    featureFlagsData = try! PropertyListSerialization.data(fromPropertyList: [:], format: .xml, options: 0)
                    eligibilityData = featureFlagsData
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
        guard let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
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
        guard let cacheData = mobileGestalt["CacheData"] as? NSMutableData else {
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
        guard let cacheData = mobileGestalt["CacheData"] as? NSMutableData,
              let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
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
        guard let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
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
            FileToRestore(from: modMGURL, to: URL(filePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"), owner: 501, group: 501),
            FileToRestore(contents: eligibilityData, to: URL(filePath: "/var/db/eligibilityd/eligibility.plist")),
            FileToRestore(contents: featureFlagsData, to: URL(filePath: "/var/preferences/FeatureFlags/Global.plist")),
        ]
    }
    
    // https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model
    // read device model from kernel
    static func machineName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    func saveProductType() {
        let cacheExtra = mobileGestalt["CacheExtra"] as! NSMutableDictionary
        cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] = productType
    }
    
    func performApplyMobileGestalt() async throws {
        applicationIcon = "showMeProgressPlease"
        applicationStatus = "Applying Tweaks..."
        
        let context = JITEnableContext.shared
        var line: String
        
        // get bookassetd container uuid
        if bookassetdUUID == nil {
            applicationStatus = "Getting bookassestd UUID..."
            Alertinator.shared.alert(title: "Books UUID Required", body: "SparseBox needs to get the UUID from bookasstd,. Please download a book from the Books app while this one is running, then come back here.", showCancel: false, actionLabel: "continue", action: {
                LSApplicationWorkspaceDefaultWorkspace().openApplication(withBundleID: "com.apple.iBooks")
            })
            
            print("Finding bookassetd container UUID...")
            print("Please open Books app and download a book to continue.")
            line = try await waitForSyslogLine(matches: { $0.contains("bookassetd") && $0.contains("/Documents/BLDownloads/") })
            
            // Return to SparseBox
            LSApplicationWorkspaceDefaultWorkspace().openApplication(withBundleID: Bundle.main.bundleIdentifier!)
            
            bookassetdUUID = line.components(separatedBy: "/var/containers/Shared/SystemGroup/")[1]
                .components(separatedBy: "/Documents/BLDownloads")[0]
            if bookassetdUUID == nil {
                applicationIcon = "xmark.circle"
                applicationStatus = "Failed to get bookassetd UUID!"
                applicationIconColor = .red
                
                Alertinator.shared.alert(title: "Error!", body: "Failed to get bookassetd container UUID from syslog.")
                return
            }
        }
        
        print("bookassetd container UUID: \(bookassetdUUID!)")
        
        // copy files from bundle to Documents folder
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let d28LocalPath = documentsDirectory.appendingPathComponent("downloads.28.sqlitedb").path
        let bldLocalPath = documentsDirectory.appendingPathComponent("BLDatabaseManager.sqlite").path
        let bundle = Bundle.main
        if !FileManager.default.fileExists(atPath: d28LocalPath),
           let resourcePath = bundle.path(forResource: "downloads.28", ofType: "sqlitedb") {
            try? FileManager.default.copyItem(atPath: resourcePath, toPath: d28LocalPath)
        }
        if !FileManager.default.fileExists(atPath: bldLocalPath),
           let resourcePath = bundle.path(forResource: "BLDatabaseManager", ofType: "sqlite") {
            try? FileManager.default.copyItem(atPath: resourcePath, toPath: bldLocalPath)
        }
        if !FileManager.default.fileExists(atPath: bldLocalPath + "-shm"),
            let resourcePath = bundle.path(forResource: "BLDatabaseManager", ofType: "sqlite-shm") {
            try? FileManager.default.copyItem(atPath: resourcePath, toPath: bldLocalPath + "-shm")
        }
        if !FileManager.default.fileExists(atPath: bldLocalPath + "-wal"),
            let resourcePath = bundle.path(forResource: "BLDatabaseManager", ofType: "sqlite-wal") {
            try? FileManager.default.copyItem(atPath: resourcePath, toPath: bldLocalPath + "-wal")
        }
        
        applicationStatus = "Patching BLDatabaseManager.sqlite..."
        print("Patching BLDatabaseManager.sqlite...")
        try Databases.patchDatabase(dbPath: d28LocalPath, uuid: bookassetdUUID!, ip: "localhost", port: Utils.port)
        
        // Kill bookassetd and Books processes to stop them from updating BLDatabaseManager.sqlite
        var processes: [Int32 : String?] = try getRunningProcesses()
        var pid_bookassetd = processes.first { $0.value?.hasSuffix("/bookassetd") == true }?.key
        var pid_Books = processes.first { $0.value?.hasSuffix("/Books") == true }?.key
        if let pid_bookassetd {
            applicationStatus = "topping bookassetd (pid \(pid_bookassetd))..."
            print("Stopping bookassetd (pid \(pid_bookassetd))...")
            try context?.killProcess(withPID: pid_bookassetd, signal: SIGSTOP)
        }
        if let pid_Books {
            applicationStatus = "Killing Books (pid \(pid_Books))..."
            print("Killing Books (pid \(pid_Books))...")
            try context?.killProcess(withPID: pid_Books, signal: SIGKILL)
        }
        
        // Upload com.apple.MobileGestalt.plist
        applicationStatus = "Uploading MobileGestalt..."
        print("Uploading com.apple.MobileGestalt.plist")
        try context?.afcPushFile(modMGURL.path(), toPath: "com.apple.MobileGestalt.plist")
        
        // Upload downloads.28.sqlitedb
        applicationStatus = "Uploading Database..."
        print("Uploading downloads.28.sqlitedb")
        try context?.afcPushFile(d28LocalPath, toPath: "Downloads/downloads.28.sqlitedb")
        try context?.afcPushFile(d28LocalPath + "-shm", toPath: "Downloads/downloads.28.sqlitedb-shm")
        try context?.afcPushFile(d28LocalPath + "-wal", toPath: "Downloads/downloads.28.sqlitedb-wal")
        // conn.close()
        
        // Kill itunesstored to trigger BLDataBaseManager.sqlite overwrite
        processes = try getRunningProcesses()
        let pid_itunesstored = processes.first { $0.value?.hasSuffix("/itunesstored") == true }?.key
        if let pid_itunesstored {
            applicationStatus = "Killing itunesstored (pid \(pid_itunesstored))..."
            print("Killing itunesstored (pid \(pid_itunesstored))...")
            try context?.killProcess(withPID: pid_itunesstored, signal: SIGKILL)
        }
        
        // Wait for itunesstored to finish download and raise an error
        applicationStatus = "Waiting for itunesstored to finish download..."
        print("Waiting for itunesstored to finish download...")
        // FIXME: syslog not working
        _ = try await waitForSyslogLine(matches: { $0.contains("Install complete for download: 6936249076851270152 result: Failed") }, timeout: 2)
        
        // Kill bookassetd and Books processes to trigger MobileGestalt overwrite
        pid_bookassetd = processes.first { $0.value?.hasSuffix("/bookassetd") == true }?.key
        pid_Books = processes.first { $0.value?.hasSuffix("/Books") == true }?.key
        if let pid_bookassetd {
            applicationStatus = "Killing bookassetd (pid \(pid_bookassetd))..."
            print("Killing bookassetd (pid \(pid_bookassetd))...")
            try context?.killProcess(withPID: pid_bookassetd, signal: SIGKILL)
        }
        if let pid_Books {
            applicationStatus = "Killing Books (pid \(pid_Books))..."
            print("Killing Books (pid \(pid_Books))...")
            try context?.killProcess(withPID: pid_Books, signal: SIGKILL)
        }
        
        // Re-open Books app
        LSApplicationWorkspaceDefaultWorkspace().openApplication(withBundleID: "com.apple.iBooks")
        LSApplicationWorkspaceDefaultWorkspace().openApplication(withBundleID: Bundle.main.bundleIdentifier!)
        
        applicationStatus = "Waiting for overwrite to complete..."
        print("Waiting for MobileGestalt overwrite to complete...")
        applicationStatus = "Tweaks Applied Successfully!"
        applicationIcon = "checkmark.circle.fill"
        applicationIconColor = .green
        let success_message = "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist) [Install-Mgr]: Marking download as [finished]"
        // FIXME: syslog not working
        _ = try await waitForSyslogLine(matches: { $0.contains(success_message) }, timeout: 3)
        
        if respring {
            print("Respringing...")
            let pid_backboardd = processes.first { $0.value?.hasSuffix("/backboardd") == true }?.key
            if let pid_backboardd {
                try context?.killProcess(withPID: pid_backboardd, signal: SIGKILL)
            }
        }
        
//        let deviceList = MobileDevice.deviceList()
//        guard deviceList.count == 1 else {
//            print("Invalid device count: \(deviceList.count)")
//            return
//        }
//        Utils.udid = deviceList.first!
//        D28BookChain.replaceMobileGestalt(udid: Utils.udid, path: "/aaaaa")
        
        /*
        MobileDevice.requireAppleFileConduitService(udid: Utils.udid) { client in
            var file: UInt64 = 0
            let ret = afc_file_open(client, "/Downloads/downloads.28.sqlitedb", AFC_FOPEN_RW, &file)
            guard ret == AFC_E_SUCCESS else {
                print("AFC open failed with code \(ret)")
                return
            }
            
            let d28LocalPath = Bundle.main.url(forResource: "downloads", withExtension: "28.sqlitedb")!
            let d28Data = try! Data(contentsOf: d28LocalPath)
            d28Data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                let writeRet = afc_file_write(client, file, ptr.baseAddress!, UInt32(d28Data.count), <#UnsafeMutablePointer<UInt32>?#>)
                guard writeRet == AFC_E_SUCCESS else {
                    print("AFC write failed with code \(writeRet)")
                    return
                }
            }
        }
         */
    }
    
    func getRunningProcesses() throws -> [Int32 : String?] {
        Dictionary(
            uniqueKeysWithValues: (try JITEnableContext.shared?.fetchProcessList() as! [[String: Any]])
                .compactMap { item in
                    guard let pid = item["pid"] as? Int32 else { return nil }
                    let path = item["path"] as? String
                    return (pid, path)
                }
        )
    }
    
    func waitForSyslogLine(matches predicate: @escaping (String) -> Bool, timeout: TimeInterval? = nil) async throws -> String {
        let result = try await withCheckedThrowingContinuation { continuation in
            var resumed = false
            JITEnableContext.shared.startSyslogRelay { line in
                if predicate(line!) {
                    resumed = true
                    continuation.resume(returning: line!)
                }
            } onError: { error in
                resumed = true
                continuation.resume(throwing: error!)
            }
            
            if let timeout {
                DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                    if resumed { return }
                    continuation.resume(returning: "Timed out waiting for syslog line.")
                }
            }
        }
        JITEnableContext.shared.stopSyslogRelay()
        return result
    }
    
    func respringDevice() {
        let context = JITEnableContext.shared
        var processes: [Int32 : String?] = try! getRunningProcesses()
        
        print("Respringing...")
        let pid_backboardd = processes.first { $0.value?.hasSuffix("/backboardd") == true }?.key
        if let pid_backboardd {
            try! context?.killProcess(withPID: pid_backboardd, signal: SIGKILL)
        }
    }
}

// i am so sorry for doing this, but it fixed the weird ui issues so womp womp
struct MobileGestaltViewer<Content: View>: View {
    let pathToGestalt = URL(fileURLWithPath: "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
    
    @State var gestaltData: [String: Any] = [:]
    @State var topLevelCache: [String: Any] = [:]
    @State var searchRequest: String = ""
    @ViewBuilder var content: Content
    
    var body: some View {
        NavigationStack {
            List {
                content
                Section(header: HeaderLabel(text: "MobileGestalt Data", icon: "doc")) {
                    DictionaryView(dictionary: topLevelCache, searchRequest: searchRequest)
                }
            }
            .navigationTitle("MobileGestalt Data")
            .searchable(text: $searchRequest, prompt: "Search Keys")
            .onAppear {
                gestaltData = loadGestaltData() as? [String: Any] ?? [:]
                topLevelCache = gestaltData["CacheExtra"] as? [String: Any] ?? [:]
            }
        }
    }

    func loadGestaltData() -> Any? {
        do {
            // this gets the data of the file
            let rawGestaltData = try Data(contentsOf: pathToGestalt)
            // this returns it as a property list
            return try PropertyListSerialization.propertyList(from: rawGestaltData, options: [], format: nil)
        } catch {
            // this comes up if something goes wrong
            Alertinator.shared.alert(title: "Error!", body: "\(error)")
            return nil
        }
    }
}

struct DictionaryView: View {
    var dictionary: [String: Any]
    var searchRequest: String = ""
    
    var body: some View {
        ForEach(searchRequest.isEmpty ? Array(dictionary.keys.sorted()) : Array(dictionary.keys.sorted()).filter { $0.localizedStandardContains(searchRequest) }, id: \.self) { key in
            let rawValue = dictionary[key] ?? "N/A"
            let value = String(describing: rawValue)
            VStack(alignment: .leading, spacing: 14) {
                if value.contains("""
                    {
                    
                    """) {
                    let nestedDictionary = rawValue as? [String: Any] ?? [:]
                    DisclosureGroup {
                        DictionaryView(dictionary: nestedDictionary)
                            .padding(.leading, 20)
                    } label: {
                        Text(key)
                    }
                } else {
                    LabeledContent(key) {
                        Text(value)
                    }
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = key
                        }) {
                            Image(systemName: "key")
                            Text("Copy Key")
                        }
                        Button(action: {
                            UIPasteboard.general.string = value
                        }) {
                            Image(systemName: "link")
                            Text("Copy Value")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        MobileGestaltView()
    }
}
