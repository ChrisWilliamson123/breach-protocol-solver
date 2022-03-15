//
//  ScannedTextView.swift
//  BreachSolver
//
//  Created by Chris on 15/03/2022.
//

import SwiftUI

struct ScannedTextView: View {
    let fontSize: CGFloat = 24
    @Binding var scannedText: RecognisedBreachText
    @Binding var alertItem: AlertItem?

    var body: some View {
        let zippedMatrixRows = Array(zip(scannedText.matrix.indices, scannedText.matrix))
        let zippedDaemonRows = Array(zip(scannedText.daemons.indices, scannedText.daemons))
        
        return VStack(spacing: 16) {
            VStack {
                Text("Matrix").font(.system(size: 28, design: .monospaced))
                ForEach(zippedMatrixRows, id: \.0) { rowIndex, rowItem in
                    let zippedCodes = Array(zip(rowItem.indices, rowItem))
                    HStack {
                        ForEach(zippedCodes, id: \.0) { colIndex, item in
                            Button {
                                self.alertItem = AlertItem(title: "Please pick the correct code",
                                                           actions: Constants.allowedCodes.map({ code in (code, { scannedText.matrix[rowIndex][colIndex] = code }) }))
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
                                                           actions: Constants.allowedCodes.map({ code in (code, { scannedText.daemons[rowIndex][colIndex] = code }) }))
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
            var buttons: [ActionSheet.Button] = alertItem.actions.map({ ActionSheet.Button.default(Text($0.title), action: $0.action) })
            buttons.append(.cancel())
            return ActionSheet(title: Text(alertItem.title), buttons: buttons)
        }
    }
}

//struct ScannedTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScannedTextView()
//    }
//}
