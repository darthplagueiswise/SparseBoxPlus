import SwiftUI
import UniformTypeIdentifiers
import PartyUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var pairingFile: String?
    @State var mbdb: Backup?
    @State var heartbeatReady = false
    @State var ddiMounted = false
    @State var showPairingFileImporter = false
    @State var showErrorAlert = false
    @State var taskRunning = false
    @State var initError: String?
    @State var lastError: String?
    @State var path = NavigationPath()
    @State private var showSettingsView: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(header: HeaderLabel(text: "Device Pairing", icon: "doc"), footer: Text(ddiMounted ? "If you've already imported a pairing file, and the things above aren't green, then make sure that you actually enabled the StikDebug VPN. Also ensure that your pairing file has not expired." : heartbeatReady ? "The Developer Disk Image is not mounted. Open StikDebug and ensure that it's mounted." : "Select or drag and drop a pairing file to continue. If you do not have one, click [here](https://docs.sidestore.io/docs/getting-started/pairing-file) to learn how to generate one.")) {
                    LabeledContent("Heartbeat Status") {
                        HStack {
                            Image(systemName: heartbeatReady ? "checkmark.circle" : "xmark.circle")
                            Text(heartbeatReady ? "Ready" : "Not Ready")
                        }
                        .foregroundStyle(heartbeatReady ? .green : .red)
                    }
                    LabeledContent("Developer Disk Image") {
                        HStack {
                            Image(systemName: ddiMounted ? "checkmark.circle" : "xmark.circle")
                            Text(ddiMounted ? "Mounted" : "Not Mounted")
                        }
                        .foregroundStyle(ddiMounted ? .green : .red)
                    }
                }
                Section(header: HeaderLabel(text: "Tweaks", icon: "wrench.and.screwdriver"), footer: Text(Restore.supportedExploitLevel() != .unsupported ? "Hide free developer apps from installd, so you could install more than 3 apps. You need to apply this for each 3 apps you install or update. **This feature is currently unavailable as of right now.**" : "")) {
                    let tempUnavailable = true
                    NavigationLink("List Installed Apps") {
                        AppListView()
                    }
                    .disabled(!ddiMounted)
                    NavigationLink("MobileGestalt Tweaks") {
                        MobileGestaltView()
                    }
                    .disabled(!ddiMounted)
                    if Restore.supportedExploitLevel() != .unsupported {
                        Button("Bypass 3-App Limit") {
                            testBypassAppLimit()
                        }
                        .disabled(tempUnavailable || Restore.supportedExploitLevel() != .dotAndSlashes || !heartbeatReady || taskRunning)
                    }
                }
            }
            .navigationTitle("SparseBox+")
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 14) {
                    Button(action: {
                        if pairingFile == nil {
                            showPairingFileImporter.toggle()
                        } else {
                            pairingFile = nil
                        }
                    }) {
                        ButtonLabel(text: pairingFile == nil ? "Import Pairing File" : "Remove Pairing File", icon: pairingFile == nil ? "arrow.down.doc" : "xmark")
                    }
                    .buttonStyle(GlassyButtonStyle(color: pairingFile == nil ? .green : .red))
                    .dropDestination(for: Data.self) { items, location in
                        guard let item = items.first else { return false }
                        pairingFile = String(decoding: item, as: UTF8.self)
                        guard pairingFile?.contains("DeviceCertificate") ?? false else {
                            Alertinator.shared.alert(title: "That's not a pairing file!", body: "Please drop a vaild pairing file and try again.")
                            pairingFile = nil
                            return false
                        }
                        savePairingFile()
                        startHeartbeat()
                        return true
                    }
                    if !ddiMounted {
                        Button(action: {
                            if let url = URL(string: "stikjit://") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            ButtonLabel(text: "Open StikDebug", icon: "bolt")
                        }
                        .buttonStyle(GlassyButtonStyle())
                    }
                }
                .modifier(OverlayBackground())
            }
            .fileImporter(isPresented: $showPairingFileImporter, allowedContentTypes: [UTType(filenameExtension: "mobiledevicepairing", conformingTo: .data)!], onCompletion: { result in
                switch result {
                case .success(let url):
                    pairingFile = try! String(contentsOf: url)
                    savePairingFile()
                    startHeartbeat()
                case .failure(let error):
                    lastError = error.localizedDescription
                    showErrorAlert.toggle()
                }
            })
            .navigationDestination(for: String.self) { view in
                if view == "Apply3AppLimitBypass" {
                    Text("TODO")
                } else {
                    Text("Unknown view: \(view)")
                }
            }
        }
        .onAppear {
            if initError != nil {
                lastError = initError
                initError = nil
                showErrorAlert.toggle()
                return
            }
            
            if pairingFile == nil {
                pairingFile = try? String(contentsOf: URL.documentsDirectory.appendingPathComponent("pairingFile.plist"))
            }
            
            if let altPairingFile = Bundle.main.object(forInfoDictionaryKey: "ALTPairingFile") as? String, altPairingFile.count > 5000, pairingFile == nil {
                pairingFile = altPairingFile
                savePairingFile()
            }
            
            if pairingFile != nil {
                startHeartbeat()
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
    func savePairingFile() {
        try? pairingFile?.write(to: URL.documentsDirectory.appendingPathComponent("pairingFile.plist"), atomically: true, encoding: .utf8)
    }

    func testBypassAppLimit() {
        guard Restore.supportedExploitLevel() == .dotAndSlashes else {
            lastError = "Unsupported iOS version. Must be running iOS 18.1b4 or older."
            showErrorAlert.toggle()
            return
        }
        Task {
            taskRunning = true
            mbdb = Restore.createBypassAppLimit()
            path.append("Apply3AppLimitBypass")
            taskRunning = false
        }
    }
    
    func startHeartbeat() {
        guard pairingFile != nil else {
            return
        }
        //let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
        DispatchQueue.global(qos: .background).async {
            print("Heartbeat: starting...")
            let completionHandler: @convention(block) (Int32, String?) -> Void = { result, message in
                if result == 0 {
                    heartbeatReady = true
                    print("Heartbeat started successfully: \(message ?? "")")
                    
                    // quick way to check if DDI is mounted
                    let ddiPath: String
                    if #available(iOS 17.0, *) {
                        ddiPath = "/System/Developer/Library"
                    } else {
                        ddiPath = "/Developer/Library"
                    }
                    ddiMounted = FileManager.default.fileExists(atPath: ddiPath)
                    
                    // TODO: mount DDI
                    //                        pubHeartBeat = true
                    //
                    //                        if FileManager.default.fileExists(atPath: URL.documentsDirectory.appendingPathComponent("DDI/Image.dmg.trustcache").path) {
                    //                            MountingProgress.shared.pubMount()
                    //                        }
                } else {
                    print("Error: \(message ?? "") (Code: \(result))")
                    DispatchQueue.main.async {
                        if result == -9 {
                            do {
                                try FileManager.default.removeItem(at: URL.documentsDirectory.appendingPathComponent("pairingFile.plist"))
                                print("Removed invalid pairing file")
                            } catch {
                                print("Error removing invalid pairing file: \(error)")
                            }
                            
                            lastError = "The pairing file is invalid or expired. Please select a new pairing file."
                            showErrorAlert.toggle()
                        } else {
                            lastError = "Failed to connect to Heartbeat (\(result)). Are you connected to WiFi or is Airplane Mode enabled? Cellular data isn’t supported. Please launch the app at least once with WiFi enabled. After that, you can switch to cellular data to turn on the VPN, and once the VPN is active you can use Airplane Mode."
                            showErrorAlert.toggle()
                        }
                    }
                }
            }
            JITEnableContext.shared.startHeartbeat(completionHandler: completionHandler, logger: nil)
        }
    }
    
    func performApply3AppLimitBypass() {
        lastError = "3 app limit bypass is temporarily disabled."
        showErrorAlert.toggle()
        /*
        let deviceList = MobileDevice.deviceList()
        guard deviceList.count == 1 else {
            print("Invalid device count: \(deviceList.count)")
            return
        }
        Utils.udid = deviceList.first!
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documentsDirectory.appendingPathComponent(Utils.udid, conformingTo: .data)
        try? FileManager.default.removeItem(at: folder)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false)
            try mbdb!.writeTo(directory: folder)
            // Restore now
            let restoreArgs = [
                "idevicebackup2",
                "-n", "restore", "--no-reboot", "--system",
                documentsDirectory.path(percentEncoded: false)
            ]
            print("Executing args: \(restoreArgs)")
            var argv = restoreArgs.map{ strdup($0) }
            let result = 0 //idevicebackup2_main(Int32(restoreArgs.count), &argv)
            print("idevicebackup2 exited with code \(result)")
            
            print()
            let log = GLOBAL_LOG.text
            if log.contains("Domain name cannot contain a slash") {
                print("Result: this iOS version is not supported.")
            } else if log.contains("crash_on_purpose") || result == 0 {
                print("Result: restore successful.")
                if reboot {
                    //MobileDevice.rebootDevice(udid: Utils.udid)
                }
            }
            
            logPipe.fileHandleForReading.readabilityHandler = nil
        } catch {
            print(error.localizedDescription)
            return
        }
         */
    }
    
    func ready() -> Bool {
        heartbeatReady
    }
}

#Preview {
    ContentView()
}
