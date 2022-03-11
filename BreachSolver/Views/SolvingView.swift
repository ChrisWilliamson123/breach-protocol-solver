//
//  SolvingView.swift
//  BreachSolver
//
//  Created by Chris on 11/03/2022.
//

import SwiftUI

struct SolvingView: View {
    @StateObject private var solver: Solver
    
    init(text: RecognisedBreachText) {
        _solver = StateObject(wrappedValue: Solver(matrix: text.matrix, daemons: text.daemons))
    }
    
    var body: some View {
        List(solver.toSolve, id: \.self) {
            SequenceView(sequence: $0.sequence, daemonIds: $0.ids.sorted(), maxDaemons: solver.maxDaemons, solvedState: $0.solvedState)
        }.onAppear {
            solver.solve()
        }.navigationTitle("Solving...")
    }
}

//struct SolvingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SolvingView()
//    }
//}
