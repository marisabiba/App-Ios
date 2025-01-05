import Foundation

struct Trip: Identifiable, Codable {
    var id = UUID()
    var name: String
    var destination: Place?
    var destinationImageUrl: String?
    var startDate: Date
    var endDate: Date
    var days: [TripDay]
    
    // Calculate number of days between dates
    var numberOfDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0 + 1
    }
    
    // Add CodingKeys to handle optional destination
    enum CodingKeys: String, CodingKey {
        case id, name, destination, destinationImageUrl, startDate, endDate, days
    }
    
    // Custom init from decoder to handle optional destination
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        destination = try container.decodeIfPresent(Place.self, forKey: .destination)
        destinationImageUrl = try container.decodeIfPresent(String.self, forKey: .destinationImageUrl)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        days = try container.decode([TripDay].self, forKey: .days)
    }
    
    // Regular init
    init(id: UUID = UUID(), name: String, destination: Place? = nil, destinationImageUrl: String? = nil, startDate: Date, endDate: Date, days: [TripDay]) {
        self.id = id
        self.name = name
        self.destination = destination
        self.destinationImageUrl = destinationImageUrl
        self.startDate = startDate
        self.endDate = endDate
        self.days = days
    }
}

struct TripDay: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var title: String
    var activities: [Activity]
    var transportationDetails: TransportationDetails
    var budgetDetails: BudgetDetails
    var checklist: [ChecklistItem]
}

struct Activity: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var title: String
    var location: String
    var notes: String
}

struct TransportationDetails: Codable {
    var mode: String
    var time: Date
}

struct BudgetDetails: Codable {
    var amount: Double
}

struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}
