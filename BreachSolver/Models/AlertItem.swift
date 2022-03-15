import Foundation

struct AlertItem: Identifiable {
    var id = UUID()
    var title: String = "Please choose correct code"
    var actions: [(title: String, action: () -> ())]
}
