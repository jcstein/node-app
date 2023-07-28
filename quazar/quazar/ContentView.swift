//
//  ContentView.swift
//  quazar
//
//  Created by Josh Stein on 6/1/23.
//

import SwiftUI
import AppKit

class ContentViewViewModel: ObservableObject {
    @Published var isRunningNode = false
    @Published var mnemonic: String?
    @Published var address: String?
    @Published var chainHeight: String?
    @Published var sampledChainHead: String?
    @Published var catchupHead: String?
    @Published var networkHeadHeight: String?
    @Published var sampledChainHeadProgress: Double = 0.0
    @Published var catchupHeadProgress: Double = 0.0
    @Published var networkHeadHeightProgress: Double = 1.0
    @Published var accountAddress: String?
    @Published var balance: Double = 0.0
    
    private var process: Process?
    private var timer: Timer?
    private var timer2: Timer?
    private var timer3: Timer?
    private var processId: Int32?
    private var terminationAttempted = false
    
    enum AlertType: Int, Identifiable {
        case mnemonicAlert
        case alreadyInitializedAlert
        case deletionSuccessAlert
        case deletionErrorAlert
        case deletionErrorAlertErr
        case deletionKeySuccessAlert
        case deletionKeyErrorAlert
        case deletionKeyErrorAlertErr
        case deletionDataSuccessAlert
        case deletionDataErrorAlert
        case deletionDataErrorAlertErr
        
        var id: Int { rawValue }
    }
    
    @Published var alertType: AlertType? = nil
    
    func initializeNode() {
        let command = "cd \(Bundle.main.resourcePath!); ./celestia light init --p2p.network arabica "
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print("Output: \(output)")
            
            if let mnemonic = extractMnemonic(from: output), let address = extractAddress(from: output) {
                DispatchQueue.main.async {
                    self.mnemonic = mnemonic
                    self.address = address
                    self.alertType = .mnemonicAlert
                }
            } else {
                DispatchQueue.main.async {
                    self.alertType = .alreadyInitializedAlert
                }
            }
        }
        task.waitUntilExit()
        let status = task.terminationStatus
        print("Exit status: \(status)")
    }
    
    func extractMnemonic(from output: String) -> String? {
        let keyword = "MNEMONIC (save this somewhere safe!!!):"
        let outputLines = output.components(separatedBy: "\n")
        if let lineIndex = outputLines.firstIndex(where: { $0.contains(keyword) }), lineIndex + 1 < outputLines.count {
            let mnemonicLine = outputLines[lineIndex + 1]
            let mnemonic = mnemonicLine.trimmingCharacters(in: .whitespacesAndNewlines)
            return mnemonic
        }
        return nil
    }
    
    func extractAddress(from output: String) -> String? {
        let keyword = "ADDRESS:"
        let outputLines = output.components(separatedBy: "\n")
        if let line = outputLines.first(where: { $0.contains(keyword) }) {
            return line.replacingOccurrences(of: keyword, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
    // handle errors for timeout
    func startNode() {
        let command = "cd \(Bundle.main.resourcePath!); ./celestia light start --core.ip consensus-full-arabica-9.celestia-arabica.com --p2p.network arabica"
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                self?.isRunningNode = false
            }
        }
        
        DispatchQueue.global().async {
            task.launch()
            self.processId = task.processIdentifier
            task.waitUntilExit()
        }
        
        isRunningNode = true
        process = task
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.querySamplingStats()
        }
        // query this once after node starts
        timer2 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.queryAccountAddress()
        }
        timer3 = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkBalance()
        }
    }
    
    func stopCommand() {
        process?.terminate()
        terminationAttempted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkIfProcessIsRunning()
        }
    }
    
    func checkIfProcessIsRunning() {
        guard let processId = processId else { return }
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", "ps -p \(processId)"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        DispatchQueue.global().async {
            task.launch()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            
            DispatchQueue.main.async {
                // Check if the process is still running
                if output?.contains("\(processId)") == true {
                    // If we've already attempted termination, kill the process forcefully
                    if self.terminationAttempted {
                        self.killProcess()
                    } else {
                        // If not, try terminating again
                        self.stopCommand()
                    }
                } else {
                    self.isRunningNode = false
                    self.timer?.invalidate()
                    self.timer2?.invalidate()
                    self.timer3?.invalidate()
                    self.timer = nil
                    self.timer2 = nil
                    self.timer3 = nil
                }
            }
        }
    }
    
    func killProcess() {
        guard let processId = processId else { return }
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", "kill -9 \(processId)"]
        
        DispatchQueue.global().async {
            task.launch()
            task.waitUntilExit()
        }
    }
    
    func querySamplingStats() {
        let command = "cd \(Bundle.main.resourcePath!); ./celestia rpc das SamplingStats --auth $(./celestia light auth admin --p2p.network arabica)"
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.terminationHandler = { process in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                do {
                    if let jsonData = output.data(using: .utf8) {
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        if let result = json?["result"] as? [String: Any] {
                            DispatchQueue.main.async {
                              if let sampledChainHead = result["head_of_sampled_chain"] as? Int {
                                  print("Sampled Chain Head: \(sampledChainHead)")
                                  self.sampledChainHead = String(sampledChainHead)
                                  if let networkHeadHeight = result["network_head_height"] as? Int {
                                      self.sampledChainHeadProgress = Double(sampledChainHead) / Double(networkHeadHeight)
                                  }
                              }
                              if let catchupHead = result["head_of_catchup"] as? Int {
                                  print("Catchup Head: \(catchupHead)")
                                  self.catchupHead = String(catchupHead)
                                  if let networkHeadHeight = result["network_head_height"] as? Int {
                                      self.catchupHeadProgress = Double(catchupHead) / Double(networkHeadHeight)
                                  }
                              }
                              if let networkHeadHeight = result["network_head_height"] as? Int {
                                  print("Network Head Height: \(networkHeadHeight)")
                                  self.networkHeadHeight = String(networkHeadHeight)
                                  self.networkHeadHeightProgress = 1.0
                              }
                          }
                        }
                    }
                } catch let error {
                    print("Failed to parse JSON: \(error)")
                }
            }
        }
        DispatchQueue.global().async {
            task.launch()
            task.waitUntilExit()
        }
    }
    // remove extra queries
    func queryAccountAddress() {
       let command = "cd \(Bundle.main.resourcePath!); ./celestia rpc state AccountAddress --auth $(./celestia light auth admin --p2p.network arabica)"
       
       let task = Process()
       task.launchPath = "/usr/bin/env"
       task.arguments = ["bash", "-c", command]
       
       let pipe = Pipe()
       task.standardOutput = pipe
       task.standardError = pipe
       
       task.terminationHandler = { process in
           let data = pipe.fileHandleForReading.readDataToEndOfFile()
           if let output = String(data: data, encoding: .utf8) {
               do {
                   if let jsonData = output.data(using: .utf8) {
                       let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                       if let result = json?["result"] as? String {
                           DispatchQueue.main.async {
                               self.accountAddress = result
                           }
                       }
                   }
               } catch let error {
                   print("Failed to parse JSON: \(error)")
               }
           }
       }
       
       DispatchQueue.global().async {
           task.launch()
           task.waitUntilExit()
       }
   }

    func deleteDataStore() {
        let fileManager = FileManager.default
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "org.joshcs.quazar")?.appendingPathComponent(".celestia-light-arabica-9/data")
        
        guard let path = url?.path else {
            print("❌ Invalid path")
            return
        }
        
        print("👀 Attempting to delete data store at: \(path)")
        
        do {
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
                print("🗑️ Node store deleted")
                DispatchQueue.main.async {
                    self.alertType = .deletionSuccessAlert
                }
            } else {
                print("❓ Data store does not exist")
                DispatchQueue.main.async {
                    self.alertType = .deletionErrorAlert
                }
            }
        } catch let error {
            print("❌ Error deleting data store: \(error)")
            DispatchQueue.main.async {
                self.alertType = .deletionErrorAlertErr
            }
        }
    }
    
    func deleteKeyStore() {
        let fileManager = FileManager.default
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "org.joshcs.quazar")?.appendingPathComponent(".celestia-light-arabica-9/keys")
        
        guard let path = url?.path else {
            print("❌ Invalid path")
            return
        }
        
        print("👀 Attempting to delete key store at: \(path)")
        
        do {
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
                print("🗑️ Key store deleted")
                DispatchQueue.main.async {
                    self.alertType = .deletionKeySuccessAlert
                }
            } else {
                print("❓ Key store does not exist")
                DispatchQueue.main.async {
                    self.alertType = .deletionKeyErrorAlert
                }
            }
        } catch let error {
            print("❌ Error deleting key store: \(error)")
            DispatchQueue.main.async {
                self.alertType = .deletionKeyErrorAlertErr
            }
        }
    }
    
    func deleteNodeStore() {
        let fileManager = FileManager.default
        let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "org.joshcs.quazar")?.appendingPathComponent(".celestia-light-arabica-9")
        
        guard let path = url?.path else {
            print("❌ Invalid path")
            return
        }
        
        print("👀 Attempting to delete node store at: \(path)")
        
        do {
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
                print("🗑️ Node store deleted")
                DispatchQueue.main.async {
                    self.alertType = .deletionDataSuccessAlert
                }
            } else {
                print("❓ Node store does not exist")
                DispatchQueue.main.async {
                    self.alertType = .deletionDataErrorAlert
                }
            }
        } catch let error {
            print("❌ Error deleting node store: \(error)")
            DispatchQueue.main.async {
                self.alertType = .deletionDataErrorAlertErr
            }
        }
    }
    
    func checkBalance() {
        let command = "cd \(Bundle.main.resourcePath!); ./celestia rpc state Balance --auth $(./celestia light auth admin --p2p.network arabica)"
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.terminationHandler = { process in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: Data(output.utf8), options: .allowFragments) as? [String: Any],
                        let result = dict["result"] as? [String: Any],
                        let amountStr = result["amount"] as? String,
                        let amountDouble = Double(amountStr) {
                        DispatchQueue.main.async {
                            self.balance = amountDouble * pow(10, -6)
                        }
                    }
                } catch let error {
                    print("Failed to parse JSON: \(error)")
                }
            }
        }
        
        DispatchQueue.global().async {
            task.launch()
            task.waitUntilExit()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewViewModel()
    @State private var showAlert = false
    @State private var showMnemonicView = false
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    var body: some View {
        VStack {
            VStack {
                if viewModel.isRunningNode {
                    HStack {
                        Text("🚀 Celestia Light Node is running")
                            .font(.largeTitle)
                            .padding(.trailing)
                        Spacer()
                        Text("Arabica devnet ☕️")
                            .font(.largeTitle)
                            .padding(.leading)
                    }.padding()
                } else {
                    VStack {
                        Text("👋 I'm quazar ✨ a macOS Celestia node client")
                            .font(.largeTitle)
                            .padding()
                    }
                }
            }
            // add X/Y blocks for sampled chain head and catchup head
            HStack {
                if viewModel.isRunningNode {
                    GroupBox {
                        VStack {
                            Text("🔬 DASer Sampling Statistics").font(.title)
                            GroupBox {
                                HStack {
                                    Text("🧪 Sampled chain head")
                                    Spacer()
                                    if viewModel.sampledChainHead == "1" {
                                        Text("🔄 node is starting up...")
                                    } else {
                                        Group {
                                            Text(viewModel.sampledChainHead ?? "🔄 fetching... ")
                                            Text(String(format: "(%.2f%%)", viewModel.sampledChainHeadProgress * 100))
                                        }
                                    }
                                }
                                ProgressView(value: viewModel.sampledChainHeadProgress)
                            }

                            GroupBox {
                                HStack {
                                    Text("🎣 Catchup head")
                                    Spacer()
                                    if viewModel.catchupHead == "1" {
                                        Text("🔄 node is starting up...")
                                    } else {
                                        Group {
                                            Text(viewModel.catchupHead ?? "🔄 fetching... ")
                                            Text(String(format: "(%.2f%%)", viewModel.catchupHeadProgress * 100))
                                        }
                                    }
                                }
                                ProgressView(value: viewModel.catchupHeadProgress)
                            }

                            GroupBox {
                                HStack {
                                    Text("🌐 Network head height")
                                    Spacer()
                                    if viewModel.networkHeadHeight == "1" {
                                        Text("🔄 node is starting up...")
                                    } else {
                                        Group {
                                            Text(viewModel.networkHeadHeight ?? "🔄 fetching... ")
                                            Text(String(format: "(%.2f%%)", viewModel.networkHeadHeightProgress * 100))
                                        }
                                    }
                                }
                                ProgressView(value: viewModel.networkHeadHeightProgress)
                            }
                        }.padding(10)
                    }
                    .padding()
                }
            }
                    if !viewModel.isRunningNode {
                            VStack {
                            GroupBox {
                                VStack {
                                    Text("🏗️ Setup & run your Node").font(.title).padding(.vertical, 5)
                                    Button(action: {
                                        viewModel.initializeNode()
                                    }) {
                                        Text("🟣 Initialize your Celestia light node").padding(.vertical, 10)
                                    }.disabled(viewModel.isRunningNode)
                                    Button(action: {
                                        viewModel.startNode()
                                    }) {
                                        Text("🟢 Start your node")
                                    }.disabled(viewModel.isRunningNode)
                                }
                                .padding(.vertical, 10)
                                .frame(minWidth: 300, maxWidth: 400)
                            }
                            GroupBox {
                                VStack {
                                    Text("⚠️ Danger zone: irreversible").font(.title3)
                                    Button(action: {
                                        viewModel.deleteDataStore()
                                    }) {
                                        Text("🗑️ Delete your data store").italic()
                                    }.disabled(viewModel.isRunningNode)
                                    Button(action: {
                                        viewModel.deleteKeyStore()
                                    }) {
                                        Text("🔐 Delete your key store").italic()
                                    }.disabled(viewModel.isRunningNode)
                                    Button(action: {
                                        viewModel.deleteNodeStore()
                                    }) {
                                        Text("🔥 Delete entire node store").italic()
                                    }.disabled(viewModel.isRunningNode)
                                }
                                .padding(.vertical, 10)
                                .frame(minWidth: 300, maxWidth: 400)
                            }
                        }
                            .padding()
                            .frame(maxWidth: 300)
                            .border(Color.gray, width: 300)
                    }
                    
                    HStack {
                        if viewModel.isRunningNode {
                            GroupBox {
                                VStack {
                                    Text("👛 Wallet").font(.title2).padding(.vertical, 3)
                                    GroupBox {
                                        Text("⚖️ Account balance")
                                            .font(.title3)
                                            .padding(.bottom, 1)
                                        VStack {
                                            Text("\(viewModel.balance, specifier: "%.6f") TIA").padding(.bottom, 2)
                                        }.disabled(!viewModel.isRunningNode)}
                                    GroupBox {
                                        if let accountAddress = viewModel.accountAddress {
                                            VStack {
                                                Text("📢 Account address")
                                                    .font(.title3).padding(.bottom, 1)
                                                Text(accountAddress)
                                                    .font(.footnote)
                                                    .multilineTextAlignment(.center)
                                                Button(action: {
                                                    copyToClipboard(accountAddress)
                                                }) {
                                                    Text("📋 Copy to clipboard")
                                                }
                                            }
                                        } else {
                                            Text("Account Address: 🔄 fetching...")
                                        }
                                    }.padding(6)
                                    Button(action: {
                                            viewModel.stopCommand()
                                        }) {
                                            Text("🔴 Stop your node")
                                    }
                                }
                            }
                            .padding()
                            .frame(minWidth: 300, maxWidth: 300)
                            .border(Color.gray, width: 300)
                            VStack {
                                GroupBox {
                                    Text("🕸️ Resources").font(.title2).padding(.vertical, 1)
                                    GroupBox {
                                        VStack {
                                            Text("🚰 Faucet").font(.title2).padding(.vertical, 3)
                                            Text("Visit the faucet to get funds")
                                            Link("faucet-arabica-9.celestia-arabica.com", destination: URL(string: "https://faucet-arabica-9.celestia-arabica.com")!)
                                        }
                                    }
                                    .padding(5)
                                    .frame(minWidth: 280, maxWidth: 280)
                                    .border(Color.gray, width: 280)
                                    GroupBox {
                                        VStack {
                                            Text("🔎 Block explorer").font(.title2).padding(.vertical, 3)
                                            Text("Visit the explorer to surf the chain")
                                            Link("explorer-arabica-9.celestia-arabica.com", destination: URL(string: "https://explorer-arabica-9.celestia-arabica.com")!)
                                        }
                                    }
                                    .padding(5)
                                    .frame(minWidth: 280, maxWidth: 280)
                                    .border(Color.gray, width: 280)
                                }
                            }
                        }
                    }
            if !viewModel.isRunningNode {
                GroupBox {
                    HStack {
                        Text("📖 Learn more about light nodes on Celestia's documentation")
                            .font(.headline)
                            .padding()
                        Link("docs.celestia.org/nodes/light-node", destination: URL(string: "https://docs.celestia.org/nodes/light-node")!)
                            .padding()
                    }
                }
                GroupBox {
                    HStack {
                        Text("🟣 Learn more about Celestia")
                            .font(.headline)
                            .padding()
                        Link("celestia.org/what-is-celestia", destination: URL(string: "https://celestia.org/what-is-celestia")!)
                            .padding()
                    }
                }
                GroupBox {
                    HStack {
                        Text("🧱 Learn more about modular blockchains")
                            .font(.headline)
                            .padding()
                        Link("celestia.org/learn", destination: URL(string: "https://celestia.org/learn")!)
                            .padding()
                    }
                }
            }
        }
        .alert(item: $viewModel.alertType) { alertType in
            switch alertType {
            case .mnemonicAlert:
                return Alert(
                    title: Text("✅ Initialization Complete"),
                    message: Text("🔐 MNEMONIC (save this somewhere safe!!!): \(viewModel.mnemonic ?? "")\n\n📢 ADDRESS: \(viewModel.address ?? "")"),
                    dismissButton: .default(Text("OK")) {
                        showMnemonicView = true
                    }
                )
            case .alreadyInitializedAlert:
                return Alert(
                    title: Text("✅ Initialization Complete"),
                    message: Text("Your node is already initialized 🫡 You can start your node."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionSuccessAlert:
                return Alert(
                    title: Text("🗑️ Success"),
                    message: Text("Data store deleted successfully."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionErrorAlertErr:
                return Alert(
                    title: Text("❌ Error"),
                    message: Text("Data store does not exist."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionErrorAlert:
                return Alert(
                    title: Text("❓ Error"),
                    message: Text("Data store not found."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionKeySuccessAlert:
                return Alert(
                    title: Text("🗑️ Success"),
                    message: Text("Key store deleted successfully."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionKeyErrorAlertErr:
                return Alert(
                    title: Text("❌ Error"),
                    message: Text("Key store does not exist."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionKeyErrorAlert:
                return Alert(
                    title: Text("❓ Error"),
                    message: Text("Key store not found."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionDataSuccessAlert:
                return Alert(
                    title: Text("🗑️ Success"),
                    message: Text("Node store deleted successfully."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionDataErrorAlertErr:
                return Alert(
                    title: Text("❌ Error"),
                    message: Text("Node store does not exist."),
                    dismissButton: .default(Text("OK"))
                )
            case .deletionDataErrorAlert:
                return Alert(
                    title: Text("❓ Error"),
                    message: Text("Node store not found."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .sheet(isPresented: $showMnemonicView) {
            VStack {
                Text("📝 Save your mnemonic somewhere safe").font(.title).padding()
                Text("🔑 This is currently the only way to back up your account").font(.title2).padding()
                VStack {
                    GroupBox {
                        Text("🔐 MNEMONIC (save this somewhere safe!!!): \(viewModel.mnemonic ?? "")")
                        Button(action: {
                            let mnemonic = viewModel.mnemonic ?? ""
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.writeObjects([mnemonic as NSString])
                        }) {
                            Text("Copy mnemonic to clipboard")
                        }
                    }
                    GroupBox {
                        Text("📢 Public address: \(viewModel.address ?? "")")
                        Button(action: {
                            let address = viewModel.address ?? ""
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.writeObjects([address as NSString])
                        }) {
                            Text("Copy address to clipboard")
                        }
                    }
                    Button("I saved my mnemonic somewhere safe") {
                        self.showMnemonicView = false
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
