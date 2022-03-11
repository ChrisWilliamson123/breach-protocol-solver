import SwiftUI

struct SequenceToSolve: Hashable {
    static func == (lhs: SequenceToSolve, rhs: SequenceToSolve) -> Bool {
        lhs.sequence == rhs.sequence && lhs.ids == rhs.ids
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sequence)
        hasher.combine(ids)
    }
    
    
    let sequence: [String] // ["BD", "1C", "1C", "7A"] etc
    let ids: Set<Int> // The daemon IDs being solved
    var solvedState: SolvedState = .pending
    
    var isSolved: Bool {
        if case .solved = solvedState { return true }
        return false
    }
    
    init(sequence: [String], ids: Set<Int>, solvedState: SolvedState = .pending) {
        self.sequence = sequence
        self.ids = ids
        self.solvedState = solvedState
    }
    
    enum SolvedState {
        case pending
        case solved(path: [Coord])
        case unsolvable
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .solved: return .green
            case .unsolvable: return .red
            }
        }
    }
    
    func solve(using matrix: [[String]], with bufferSize: Int) -> SolvedState {
        let topRow = matrix[0]
//        for i in 0..<bufferHoldableSequences.count {
        let firstCodeInSequence = sequence[0]
        if sequence.count == bufferSize && !topRow.contains(firstCodeInSequence) {
            print("Can't get a solution for sequence:", sequence)
            return .unsolvable
        }

        var startColumnIndexes: [Int] = []
        for i in (0..<topRow.count) {
            if topRow[i] == firstCodeInSequence {
                startColumnIndexes.insert(i, at: 0)
            } else {
                startColumnIndexes.append(i)
            }
        }
        let s = sequence
        for startColumnIndex in startColumnIndexes {
            let result = dijkstra(graph: [],
                                  source: Node(value: topRow[startColumnIndex], coord: .init(x: startColumnIndex, y: 0)),
                                  targetReachedFunc: { potentialTarget in potentialTarget.value.contains(s.joined())},
                                  getNeighbours: { (current, depth) in
                // Reached max depth, no more neighbours possible
                if depth == bufferSize-1 { return [] }

                // If depth is even, return other items in current column
                if depth % 2 == 0 {
                    let columnIndex = current.coord.x
                    var allCol = (0..<matrix.count).map({ Node(value: current.value + matrix[$0][columnIndex], coord: .init(x: columnIndex, y: $0))  })
                    allCol.remove(at: current.coord.y)
                    return Set(allCol)
                    // If depth is odd, return other items in current row
                } else {
                    let rowIndex = current.coord.y
                    var allCol = (0..<matrix.count).map({ Node(value: current.value + matrix[rowIndex][$0], coord: .init(x: $0, y: rowIndex))  })
                    allCol.remove(at: current.coord.x)
                    return Set(allCol)
                }
            },
                                  getDistanceBetween: { (_, _) in return 1 })
            guard let target = result.chain.first(where: { $0.key.value.contains(sequence.joined()) })?.key else {
                print("No result found for sequence:", sequence)
                continue
            }

            print("Result found for sequence:", sequence, target.value)
            
            // Get the path
            var current: Node = result.chain[target]!!
            var path: [Coord] = [target.coord, current.coord]
            while result.chain[current] != nil {
                current = result.chain[current]!!
                path.append(current.coord)
            }
            return .solved(path: path.reversed())
        }

        return .unsolvable
    }
}
