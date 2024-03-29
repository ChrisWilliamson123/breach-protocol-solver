//
//  SolvingView.swift
//  BreachSolver
//
//  Created by Chris on 11/03/2022.
//

import SwiftUI

struct SolvingView: View {
    @StateObject private var solver: Solver
    
    init(text: RecognisedBreachText, bufferSize: Int) {
        _solver = StateObject(wrappedValue: Solver(matrix: text.matrix, daemons: text.daemons, bufferSize: bufferSize))
    }
    
    var body: some View {
        List(solver.toSolve, id: \.self) { toSolve in
            NavigationLink {
                if case let .solved(path) = toSolve.solvedState {
                    PathedMatrixView(matrix: solver.matrix, coords: path)
                } else {
                    EmptyView()
                }
            } label: {
                SequenceView(sequence: toSolve.sequence, daemonIds: toSolve.ids.sorted(), maxDaemons: solver.maxDaemons, solvedState: toSolve.solvedState)
            }.disabled(!toSolve.isSolved)

        }.onAppear {
            if solver.toSolve.count == 0 {
                solver.solve()
            }
        }.navigationTitle("Solving...")
    }
}
