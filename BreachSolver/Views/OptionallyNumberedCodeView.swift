//
//  OptionallyNumberedCodeView.swift
//  BreachSolver
//
//  Created by Chris on 11/03/2022.
//

import SwiftUI

struct OptionallyNumberedCodeView: View {
    let code: String
    let number: Int?
    
    init(code: String, number: Int? = nil) {
        self.code = code
        self.number = number
    }

    var body: some View {
        ZStack {
            Text(code).font(.system(size: 28, design: .monospaced))
            number.map({
                Text(String($0))
                    .font(.system(size: 14, design: .monospaced))
                    .offset(x: -18, y: -18)
            })
        }
    }
}

struct OptionallyNumberedCodeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OptionallyNumberedCodeView(code: "E9", number: 1)
            OptionallyNumberedCodeView(code: "BD")
        }
    }
}
