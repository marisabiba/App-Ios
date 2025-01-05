import Foundation

struct Trip: Identifiable, Codable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var days: [TripDay]
    
    // Calculate number of days between dates
    var numberOfDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return days + 1  // Add 1 to include both start and end dates
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
