import FlyingFox
import SQLite3
import SwiftUI
import UniformTypeIdentifiers

var weOnADebugBuild: Bool = false

extension UIDocumentPickerViewController {
    @objc func fix_init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) -> UIDocumentPickerViewController {
        return fix_init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}

@main
struct MyApp: App {
    @StateObject private var appData = AppData.shared
    
    init() {
        //setenv("RUST_LOG", "trace", 1)
        //set_debug(true)
        Task.detached {
            Utils.port = try Utils.reservePort()
            
            let server = HTTPServer(port: Utils.port)
            await server.appendRoute("GET /*", to: DirectoryHTTPHandler(root: URL.documentsDirectory))
            try await server.run()
        }
        
        // Fix file picker
        let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.fix_init(forOpeningContentTypes:asCopy:)))!
        let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:)))!
        method_exchangeImplementations(origMethod, fixMethod)
        #if DEBUG
        weOnADebugBuild = true
        #else
        weOnADebugBuild = false
        #endif
    }
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appData)
        }
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}


extension EdgeInsets {
    static let dropdownRowInsets = EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
    static let itemRowInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
}

func doubleSystemVersion() -> Double {
    let rawSystemVersion = UIDevice.current.systemVersion
    let parsedSystemVersion = rawSystemVersion.split(separator: ".").prefix(2).joined(separator: ".")
    return Double(parsedSystemVersion) ?? 0.0
}
