//
//  HomepageFooterView.swift
//  BreachSolver
//
//  Created by Chris on 15/03/2022.
//

import SwiftUI

struct HomepageFooterView: View {
    @Binding var bufferSize: Double
    @Binding var showingScanningView: Bool
    
    var body: some View {
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
    }
}

struct HomepageFooterView_Previews: PreviewProvider {
    static var previews: some View {
        HomepageFooterView(bufferSize: .constant(6), showingScanningView: .constant(false))
    }
}
