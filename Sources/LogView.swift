import SwiftUI

class LogModel: ObservableObject {
    @Published var text = ""
    
    func append(_ msg: String) {
        text += msg
    }
}

let logPipe = Pipe()
let GLOBAL_LOG = LogModel()

struct LogView: View {
    @StateObject private var log = GLOBAL_LOG
    @State var ran = false
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    Text(GLOBAL_LOG.text)
                        .padding(.top)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .multilineTextAlignment(.leading)
                    Spacer()
                        .id(0)
                }
                .onAppear {
                    guard !ran else { return }
                    ran = true
                    
                    logPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                        let data = fileHandle.availableData
                        if !data.isEmpty, var logString = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                if logString.contains(Utils.udid) {
                                    logString = logString.replacingOccurrences(of: Utils.udid, with: "<redacted>")
                                }
                                log.append(logString)
                                proxy.scrollTo(0)
                            }
                        }
                    }
                }
            }
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = GLOBAL_LOG.text
            } label: {
                Label("Copy Output", systemImage: "doc.on.doc")
            }
        }
    }
    
    init() {
        setvbuf(stdout, nil, _IOLBF, 0) // make stdout line-buffered
        setvbuf(stderr, nil, _IONBF, 0) // make stderr unbuffered
        
        // create the pipe and redirect stdout and stderr
        dup2(logPipe.fileHandleForWriting.fileDescriptor, fileno(stdout))
        dup2(logPipe.fileHandleForWriting.fileDescriptor, fileno(stderr))
    }
}
