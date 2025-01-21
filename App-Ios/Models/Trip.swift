import Foundation
import SwiftUI

struct Trip: Identifiable, Codable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var days: [TripDay]
    var localCurrency: String
    
    init(name: String, startDate: Date, endDate: Date, days: [TripDay], localCurrency: String = "EUR") {
        self.id = UUID()
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.days = days
        self.localCurrency = localCurrency
    }
    
    var numberOfDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return days + 1  
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
    var category: ActivityCategory
}

struct TransportationDetails: Codable {
    var mode: String
    var time: Date
}

struct BudgetDetails: Codable {
    var totalBudget: Double
    var expenses: [BudgetExpense]
    var currency: String // Base currency (e.g., "USD")
    
    var remainingBudget: Double {
        totalBudget - expenses.reduce(0) { $0 + $1.amount }
    }
}

struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}

enum ActivityCategory: String, Codable, CaseIterable {
    case sightseeing = "Sightseeing"
    case dining = "Dining"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case transportation = "Transportation"
    case accommodation = "Accommodation"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .sightseeing: return "camera"
        case .dining: return "fork.knife"
        case .shopping: return "bag"
        case .entertainment: return "ticket"
        case .transportation: return "car"
        case .accommodation: return "house"
        case .other: return "square.grid.2x2"
        }
    }
    
    var color: Color {
        switch self {
        case .sightseeing: return .blue
        case .dining: return .orange
        case .shopping: return .green
        case .entertainment: return .purple
        case .transportation: return .red
        case .accommodation: return .brown
        case .other: return .gray
        }
    }
}

struct BudgetExpense: Identifiable, Codable, Equatable {
    var id: UUID
    var amount: Double
    var currency: String
    var category: BudgetCategory
    var note: String
    var convertedAmount: Double?
    var date: Date?
    
    static func == (lhs: BudgetExpense, rhs: BudgetExpense) -> Bool {
        lhs.id == rhs.id &&
        lhs.amount == rhs.amount &&
        lhs.currency == rhs.currency &&
        lhs.category == rhs.category &&
        lhs.note == rhs.note &&
        lhs.convertedAmount == rhs.convertedAmount &&
        lhs.date == rhs.date
    }
}

enum BudgetCategory: String, Codable, CaseIterable, Equatable {
    case food = "Food"
    case transportation = "Transportation"
    case accommodation = "Accommodation"
    case activities = "Activities"
    case shopping = "Shopping"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .accommodation: return "house.fill"
        case .activities: return "figure.walk"
        case .shopping: return "bag.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transportation: return .blue
        case .accommodation: return .green
        case .activities: return .purple
        case .shopping: return .pink
        case .other: return .gray
        }
    }
}
