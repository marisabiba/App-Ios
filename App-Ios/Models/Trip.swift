import Foundation

struct Trip: Identifiable, Codable {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    
    init(id: UUID = UUID(), name: String, startDate: Date, endDate: Date) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}
