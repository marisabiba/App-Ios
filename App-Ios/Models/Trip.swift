import Foundation

struct Trip: Identifiable {
    let id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var days: [Day]
}
