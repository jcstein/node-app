//
//  ContentView.swift
//  node-app
//
//  Created by Josh Stein on 6/1/23.
//

import SwiftUI

class ContentViewViewModel: ObservableObject {
    @Published var isRunningNode = false
    @Published var mnemonic: String?
    @Published var address: String?
    @Published var chainHeight: String?

    private var process: Process?
    private var timer: Timer?
    private var processId: Int32?
    private var terminationAttempted = false

    enum AlertType: Int, Identifiable {
        case mnemonicAlert
        case alreadyInitializedAlert

        var id: Int { rawValue }
    }
    
    @Published var alertType: AlertType? = nil
    
    func initializeNode() {
        let command = "cd \(Bundle.main.resourcePath!); ./celestia light init --p2p.network arabica"
        
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
    
    func startNode() {
        let command = "cd \(Bundle.main.resourcePath!); ./celestia light start --core.ip consensus-full-arabica-8.celestia-arabica.com --gateway --gateway.addr 127.0.0.1 --gateway.port 26659 --p2p.network arabica"
        
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

        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.checkChainHeight()
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
                    self.timer = nil
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

    func checkChainHeight() {
        let command = "curl -s -X GET http://localhost:26659/head"
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.terminationHandler = { process in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if data.isEmpty {
                print("No data received from API")
                return
            }

            if let output = String(data: data, encoding: .utf8) {
                do {
                    if let dict = try JSONSerialization.jsonObject(with: Data(output.utf8), options: []) as? [String: Any],
                       let headerDict = dict["header"] as? [String: Any],
                       let height = headerDict["height"] as? String {
                        DispatchQueue.main.async {
                            self.chainHeight = height
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
       let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "gm.node-app")?.appendingPathComponent(".celestia-light-arabica-8/data")

       guard let path = url?.path else {
           print("❌ Invalid path")
           return
       }

       print("👀 Attempting to delete data store at: \(path)")

       do {
           if fileManager.fileExists(atPath: path) {
               try fileManager.removeItem(atPath: path)
               print("🗑️ Node store deleted")
           } else {
               print("❓ Data store does not exist")
           }
       } catch let error {
           print("❌ Error deleting data store: \(error)")
       }
   }

   func deleteKeyStore() {
       let fileManager = FileManager.default
       let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "gm.node-app")?.appendingPathComponent(".celestia-light-arabica-8/keys")

       guard let path = url?.path else {
           print("❌ Invalid path")
           return
       }

       print("👀 Attempting to delete key store at: \(path)")

       do {
           if fileManager.fileExists(atPath: path) {
               try fileManager.removeItem(atPath: path)
               print("🗑️ Key store deleted")
           } else {
               print("❓ Key store does not exist")
           }
       } catch let error {
           print("❌ Error deleting key store: \(error)")
       }
   }

   func deleteNodeStore() {
       let fileManager = FileManager.default
       let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "gm.node-app")?.appendingPathComponent(".celestia-light-arabica-8")

       guard let path = url?.path else {
           print("❌ Invalid path")
           return
       }

       print("👀 Attempting to delete node store at: \(path)")

       do {
           if fileManager.fileExists(atPath: path) {
               try fileManager.removeItem(atPath: path)
               print("🗑️ Node store deleted")
           } else {
               print("❓ Node store does not exist")
           }
       } catch let error {
           print("❌ Error deleting node store: \(error)")
       }
   }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewViewModel()
    @State private var balance: Double = 0.0
    
    var body: some View {
        VStack {
            Text("Light Node Control Panel")
                .font(.largeTitle)
                .padding()
            Text("Arabica devnet ☕️")
                .font(.headline)
            HStack {
                VStack {
                    GroupBox {
                        VStack {
                            Button(action: {
                                viewModel.initializeNode()
                            }) {
                                Text("🟣 Initialize your Celestia light node")
                            }.disabled(viewModel.isRunningNode).font(.headline)
                            
                            Button(action: {
                                viewModel.startNode()
                            }) {
                                Text("🟢 Start your node")
                            }.disabled(viewModel.isRunningNode).font(.headline)
                        }
                        .padding()
                    }
                    GroupBox {
                        VStack {
                            Text("⚠️ Danger zone: irreversible").font(.headline)
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
                        .padding()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.gray, width: 300)
                GroupBox {
                    VStack {
                        if viewModel.isRunningNode {
                            ProgressView("🟢 Your light node is running...")
                                .padding()
                        }
                        Button(action: {
                            viewModel.stopCommand()
                        }) {
                            Text("🔴 Stop your node")
                        }.disabled(!viewModel.isRunningNode)
                    }
                    .padding()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.gray, width: 300)
            }
            .padding(.vertical, 10)
            HStack {
                if viewModel.isRunningNode {
                    VStack {
                        GroupBox {
                            VStack {
                                Button(action: {
                                    checkBalance()
                                }) {
                                    Text("🪙 Check your balance").font(.headline)
                                }
                                
                                Text("\(balance, specifier: "%.6f") TIA")
                            }.padding()
                        }
                        
                        Text("⛓️ Chain height: \(viewModel.chainHeight ?? "🔄 fetching... ")")
                            .padding()
                    }
                    .padding()
                }
            }
        }
        .alert(item: $viewModel.alertType) { alertType in
            switch alertType {
            case .mnemonicAlert:
                return Alert(
                    title: Text("✅ Initialization Complete"),
                    message: Text("🔐 MNEMONIC (save this somewhere safe!!!): \(viewModel.mnemonic ?? "")\n\n📢 ADDRESS: \(viewModel.address ?? "")"),
                    dismissButton: .default(Text("OK"))
                )
            case .alreadyInitializedAlert:
                return Alert(
                    title: Text("✅ Initialization Complete"),
                    message: Text("Your node is already initialized 🫡"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func checkBalance() {
        let command = "curl -s -X GET http://localhost:26659/balance"
        
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
                    if let dict = try JSONSerialization.jsonObject(with: Data(output.utf8), options: []) as? [String: Any],
                       let amountStr = dict["amount"] as? String,
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
