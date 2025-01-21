import Foundation
import SwiftUI

struct Trip: Identifiable, Codable {
    var id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var days: [TripDay]
    
    
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

enum BudgetCategory: String, Codable, CaseIterable {
    case accommodation = "Accommodation"
    case dining = "Dining"
    case transportation = "Transportation"
    case activities = "Activities"
    case shopping = "Shopping"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .accommodation: return "house"
        case .dining: return "fork.knife"
        case .transportation: return "car"
        case .activities: return "ticket"
        case .shopping: return "bag"
        case .other: return "circle.grid.cross"
        }
    }
    
    var color: Color {
        switch self {
        case .accommodation: return .brown
        case .dining: return .orange
        case .transportation: return .blue
        case .activities: return .purple
        case .shopping: return .green
        case .other: return .gray
        }
    }
}

struct BudgetExpense: Identifiable, Codable {
    var id = UUID()
    var category: BudgetCategory
    var amount: Double
    var note: String
}
