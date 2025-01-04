
import Foundation

struct Trip: Identifiable, Codable {
    var id = UUID()
    let name: String
    let startDate: Date
    let endDate: Date
}
