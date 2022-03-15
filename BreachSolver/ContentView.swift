//
//  ContentView.swift
//  BreachSolver
//
//  Created by Chris on 08/03/2022.
//

import SwiftUI
import Algorithms

struct ContentView: View {
    @State private var showingScanningView = false
    @State private var alertItem: AlertItem?
    @State private var bufferSize: Double = 6
    @State private var recognizedText: RecognisedBreachText?
//    @State private var recognizedText: RecognisedBreachText? = Constants.testTexts[2]
    
    var body: some View {
        NavigationView {
            VStack {
                if let recognizedText = recognizedText {
                    ScrollView {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.gray.opacity(0.2))
                            
                            VStack(spacing: 16) {
                                createScannedTextView(using: recognizedText)
                                NavigationLink(destination: SolvingView(text: recognizedText, bufferSize: Int(bufferSize))) {
                                    Text("SOLVE")
                                        .font(.system(size: 24, design: .monospaced))
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Capsule().fill(.blue))
                                }.disabled(!recognizedText.canSolve)
                            }.padding()
                        }.padding()
                    }
                } else {
                    InstructionsView()
                }
                
                Spacer()
                
                HomepageFooterView(bufferSize: $bufferSize, showingScanningView: $showingScanningView)
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
