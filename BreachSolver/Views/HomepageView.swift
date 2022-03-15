//
//  ContentView.swift
//  BreachSolver
//
//  Created by Chris on 08/03/2022.
//

import SwiftUI
import Algorithms

struct HomepageView: View {
    @State private var showingScanningView = false
    @State private var alertItem: AlertItem?
    @State private var bufferSize: Double = 6
//    @State private var recognizedText: RecognisedBreachText?
    @State private var recognizedText: RecognisedBreachText? = Constants.testTexts[0]
    
    var body: some View {
        NavigationView {
            VStack {
                if let recognizedText = recognizedText {
                    ScrollView {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.gray.opacity(0.2))
                            
                            VStack(spacing: 16) {
                                ScannedTextView(scannedText: Binding($recognizedText)!, alertItem: $alertItem)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomepageView()
    }
}
