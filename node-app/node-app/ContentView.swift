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
    
    private var process: Process?
    
    func runCommand1() {
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
                self.mnemonic = mnemonic
                self.address = address
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
    
    func runCommand2() {
        let command = "cd \(Bundle.main.resourcePath!); ./celestia light start --core.ip https://consensus-full-arabica-8.celestia-arabica.com/ --gateway --gateway.addr 127.0.0.1 --gateway.port 26659 --p2p.network arabica"
        
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
            task.waitUntilExit()
        }
        
        isRunningNode = true
        process = task
    }
    
    func stopCommand() {
        process?.terminate()
        isRunningNode = false
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewViewModel()
    @State private var balance: String = ""
    @State private var isShowingMnemonicAlert = false
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.runCommand1()
                isShowingMnemonicAlert = true
            }) {
                Text("Initialize a Celestia light node")
            }
            
            Button(action: {
                viewModel.runCommand2()
            }) {
                Text("Start the node")
            }
            
            Button(action: {
                viewModel.stopCommand()
            }) {
                Text("Stop the node")
            }
            
            Spacer()
                .frame(height: 20) // Add space here
            
            if viewModel.isRunningNode {
                ProgressView("Node is running...")
                    .padding()
                
                Button(action: {
                    checkBalance()
                }) {
                    Text("Check Your Balance")
                }
                
                Text(balance)
                    .padding()
            }
        }
        .padding(.vertical, 10)
        .alert(isPresented: $isShowingMnemonicAlert) {
            Alert(
                title: Text("Initialization Complete"),
                message: Text("MNEMONIC (save this somewhere safe!!!): \(viewModel.mnemonic ?? "")\n\nADDRESS: \(viewModel.address ?? "")"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func checkBalance() {
        let command = "curl -X GET http://localhost:26659/balance"
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.terminationHandler = { process in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    balance = output
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
