//
//  PathedMatrixView.swift
//  BreachSolver
//
//  Created by Chris on 11/03/2022.
//

import SwiftUI

struct PathedMatrixView: View {
    let matrix: [[String]]
    let coords: [Coord]
    let spacing: CGFloat = 14

    var body: some View {
        let zippedMatrixRows = Array(zip(matrix.indices, matrix))
        return VStack(spacing: spacing) {
            ForEach(zippedMatrixRows, id: \.0) { rowIndex, rowItem in
                let zippedCodes = Array(zip(rowItem.indices, rowItem))
                HStack(spacing: spacing) {
                    ForEach(zippedCodes, id: \.0) { colIndex, item in
                        let index = coords.firstIndex(of: .init(x: colIndex, y: rowIndex))
                        OptionallyNumberedCodeView(code: item, number: index != nil ? index! + 1 : nil)
                    }
                }
            }
        }
    }
}

//struct PathedMatrixView_Previews: PreviewProvider {
//    static var previews: some View {
//        PathedMatrixView(matrix: Constants.textMatrix, coords: [.init(x: 2, y: 0), .init(x: 2, y: 5)])
//    }
//}
