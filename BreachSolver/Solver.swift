import Combine
import Foundation

class Solver: ObservableObject {
//    let daemons: [Daemon] = [
//        .init(sequence: ["1C", "E9"], id: 1),
//        .init(sequence: ["1C", "1C", "1C"], id: 2),
//        .init(sequence: ["E9", "BD", "1C"], id: 3)
//    ]
//    let matrix: [[String]] = [
//        ["55", "E9", "E9", "55", "BD"],
//        ["1C", "BD", "E9", "1C", "E9"],
//        ["BD", "1C", "1C", "55", "1C"],
//        ["BD", "BD", "BD", "E9", "1C"],
//        ["55", "BD", "1C", "55", "E9"]
//    ]
    
    let daemons: [Daemon]
    let matrix: [[String]]
    
    init(matrix: [[String]], daemons: [[String]], bufferSize: Int) {
        self.matrix = matrix
        self.daemons = daemons.enumerated().map({ (index, sequence) in Daemon(sequence: sequence, id: index + 1) })
        self.bufferSize = bufferSize
        self.maxDaemons = daemons.count
    }
    
//    let daemons: [Daemon] = [
//        .init(sequence: ["1C", "BD", "1C"], id: 1),
//        .init(sequence: ["7A", "55", "BD"], id: 2),
//        .init(sequence: ["1C", "55", "7A"], id: 3)
//    ]
//    let matrix: [[String]] = [
//        ["1C", "55", "55", "55", "1C", "55"],
//        ["1C", "1C", "55", "BD", "1C", "7A"],
//        ["1C", "7A", "55", "7A", "1C", "1C"],
//        ["1C", "1C", "7A", "7A", "E9", "BD"],
//        ["1C", "1C", "55", "E9", "1C", "7A"],
//        ["1C", "55", "BD", "1C", "BD", "1C"],
//    ]
    
    let bufferSize: Int
    let maxDaemons: Int
    @Published var toSolve: [SequenceToSolve] = []
    
    func solve() {
        let sequencesToSolve = buildSequencesToSolve()
        DispatchQueue.main.async {
            self.toSolve = sequencesToSolve
            
            DispatchQueue.global(qos: .userInitiated).async {
                for i in 0..<self.toSolve.count {
                    let seq = self.toSolve[i]
                    let result = seq.solve(using: self.matrix, with: self.bufferSize)
                    DispatchQueue.main.async {
                        self.toSolve[i] = .init(sequence: seq.sequence, ids: seq.ids, solvedState: result)
                    }
                    do {
                        sleep(1)
                    }
                }
            }
        }
    }
    
    private func buildSequencesToSolve() -> [SequenceToSolve] {
        // Get all the permutations of possible daemons from length 1 to length n where n is max number of daemons
        let daemonPermutations = daemons.permutations(ofCount: 1...)

        // Holds sequences that are merged together from different daemons, removing overlapping character sets
        // Also includes the daemons that have been merged
        var mergedDaemonSequences: [(sequence: [String], daemonIds: Set<Int>)] = []
        for permutation in daemonPermutations {
            if permutation.count == 1 { mergedDaemonSequences.append((permutation[0].sequence, [permutation[0].id])); continue }
            
            var finalSequence = permutation[0].sequence
            for sequenceIndex in 1..<permutation.count {
                // If the start of the current sequence is the same as the end of the previous sequence, merge them together, removing one instance of the duplicate
                if permutation[sequenceIndex].sequence[0] == permutation[sequenceIndex-1].sequence.last! {
                    finalSequence.append(contentsOf: permutation[sequenceIndex].sequence[1..<permutation[sequenceIndex].sequence.count])
                } else {
                    finalSequence.append(contentsOf: permutation[sequenceIndex].sequence)
                }
            }
            mergedDaemonSequences.append((finalSequence, Set(permutation.map({ $0.id }))))
        }

        // Sequences that can fit in the buffer. Reversing ensures the longest ones are first (permutations does smallest perms first)
        let bufferHoldableSequences = Array(mergedDaemonSequences.filter({ $0.sequence.count <= bufferSize }).reversed())
        return bufferHoldableSequences.map({ SequenceToSolve(sequence: $0.sequence, ids: $0.daemonIds) })
        
    }
}
