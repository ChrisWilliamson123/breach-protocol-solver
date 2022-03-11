//
//  ContentView.swift
//  BreachSolver
//
//  Created by Chris on 08/03/2022.
//

import SwiftUI
import Algorithms

struct Constants {
    static let allowedCodes = ["1C", "BD", "FF", "7A", "E9", "55"]
    static let textMatrix: [[String]] = [
        ["1C", "1C", "1C", "BD", "FF", "1C", "7A"],
        ["7A", "1C", "1C", "7A", "7A", "E9", "BD"],
        ["55", "7A", "BD", "7A", "1C", "1C", "55"],
        ["1C", "7A", "BD", "E9", "7A", "1C", "1C"],
        ["1C", "7A", "1C", "7A", "E9", "55", "55"],
        ["55", "55", "55", "7A", "55", "7A", "1C"],
        ["1C", "1C", "1C", "E9", "FF", "E9", "55"]
    ]
    static let testDaemons: [[String]] = [ ["7A", "1C", "55"], ["1C", "1C", "55"], ["55", "55", "7A"] ]
}

struct ContentView: View {
    struct AlertItem: Identifiable {
        var id = UUID()
        var title: String = "Please choose correct code"
        var actions: [(title: String, action: () -> ())]
    }
    
    @State private var showingScanningView = false
    @State private var alertItem: AlertItem?
    @State private var bufferSize = 6
//    @State private var recognizedText: RecognisedBreachText?
    @State private var recognizedText: RecognisedBreachText? = RecognisedBreachText(matrix: Constants.textMatrix, daemons: Constants.testDaemons)
    
    var body: some View {
        NavigationView {
            VStack {
                recognizedText.map({ text in
                    ScrollView {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.gray.opacity(0.2))
                            
                            VStack(spacing: 16) {
                                createScannedTextView(using: text)
                                NavigationLink(destination: SolvingView(text: text, bufferSize: bufferSize)) {
                                    Text("SOLVE")
                                        .font(.system(size: 24, design: .monospaced))
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Capsule().fill(.blue))
                                }.disabled(!text.canSolve)
                            }.padding()
                        }.padding()
                    }
                })
                
                if recognizedText == nil {
                    InstructionsView()
                }
                
                Spacer()
                
                HStack {
                    Stepper("Buffer size: \(Int(bufferSize))", value: $bufferSize, in: 4...9, step: 1).frame(width: 230)
                    Spacer()
                    
                    Button(action: {
                        showingScanningView = true
                    }) {
                        Text("SCAN")
                    }
                    .font(.system(size: 16, design: .monospaced))
                    .padding()
                    .foregroundColor(.white)
                    .background(Capsule().fill(.blue))
                }
                .padding()
            }
            .navigationBarTitle("Breach Protocol Solver")
            .sheet(isPresented: $showingScanningView) {
                ScanDocumentView(recognizedText: self.$recognizedText)
            }
        }
    }
}

extension ContentView {
    private func createScannedTextView(using breachText: RecognisedBreachText) -> some View {
        let fontSize: CGFloat = 24
        
        let zippedMatrixRows = Array(zip(breachText.matrix.indices, breachText.matrix))
        let zippedDaemonRows = Array(zip(breachText.daemons.indices, breachText.daemons))
        return VStack(spacing: 16) {
            VStack {
                Text("Matrix").font(.system(size: 28, design: .monospaced))
                ForEach(zippedMatrixRows, id: \.0) { rowIndex, rowItem in
                    let zippedCodes = Array(zip(rowItem.indices, rowItem))
                    HStack {
                        ForEach(zippedCodes, id: \.0) { colIndex, item in
                            Button {
                                self.alertItem = AlertItem(title: "Please pick the correct code",
                                                           actions: Constants.allowedCodes.map({ code in (code, { self.recognizedText?.matrix[rowIndex][colIndex] = code }) }))
                            } label: {
                                Text(item)
                                    .font(.system(size: fontSize, design: .monospaced))
                                    .foregroundColor(Constants.allowedCodes.contains(item) ? .green : .red)
                            }
                        }
                    }
                }
            }
            
            VStack {
                
                Text("Daemons").font(.system(size: 28, design: .monospaced))
                ForEach(zippedDaemonRows, id: \.0) { rowIndex, rowItem in
                    let zippedCodes = Array(zip(rowItem.indices, rowItem))
                    HStack {
                        ForEach(zippedCodes, id: \.0) { colIndex, item in
                            Button {
                                self.alertItem = AlertItem(title: "Please pick the correct code",
                                                           actions: Constants.allowedCodes.map({ code in (code, { self.recognizedText?.daemons[rowIndex][colIndex] = code }) }))
                            } label: {
                                Text(item)
                                    .font(.system(size: fontSize, design: .monospaced))
                                    .foregroundColor(Constants.allowedCodes.contains(item) ? .green : .red)
                            }
                        }
                    }
                }
            }
        }
        .actionSheet(item: $alertItem) { alertItem in
            var buttons: [ActionSheet.Button] = alertItem.actions.map({ action in
                return ActionSheet.Button.default(Text(action.title), action: action.action)
            })
            buttons.append(.cancel())
            return ActionSheet(title: Text(alertItem.title), buttons: buttons)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
