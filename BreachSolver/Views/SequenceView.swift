//
//  SequenceView.swift
//  BreachSolver
//
//  Created by Chris on 10/03/2022.
//

import SwiftUI

struct SequenceView: View {
    let sequence: [String]
    let daemonIds: [Int]
    let maxDaemons: Int
    let solvedState: SequenceToSolve.SolvedState
    
    let bodyFont: Font = .system(size: 16, design: .monospaced)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(sequence.joined(separator: ",")).font(bodyFont)
                HStack {
                    ForEach(1...maxDaemons, id: \.self) { daemonId in
                        Circle()
                            .fill(daemonIds.contains(daemonId) ? solvedState.color : Color(uiColor: .gray.withAlphaComponent(0.5)))
                            .frame(width: 10, height: 10)
                    }
                }
                if case let .solved(path) = solvedState {
                    Text(path.map({ "(\($0.x), \($0.y))" }).joined(separator: ", "))
                } else {
                    Text("No path found")
                }
            }
            Spacer()
            if case .pending = solvedState { ProgressView() }
        }
        .foregroundColor(solvedState.color)
    }
}

struct SequenceView_Previews: PreviewProvider {
    static var previews: some View {
        SequenceView(sequence: ["1C", "E9", "1C", "1C", "1C"],
                     daemonIds: [1, 2],
                     maxDaemons: 3,
                     solvedState: .solved(path: [.init(x: 1, y: 0), .init(x: 1, y: 4)]))
    }
}
