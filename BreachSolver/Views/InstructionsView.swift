//
//  InstructionsView.swift
//  BreachSolver
//
//  Created by Chris on 11/03/2022.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("1. Tap the 'scan' button below to open camera")
            Text("2. Scan the code matrix")
            Text("3. Scan the daemons")
            Text("4. Tap on a code to correct it")
            Text("5. Tap the 'solve' button")
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
