import Foundation

struct Trip: Identifiable {
    let id = UUID()
    var name: String
    var startDate: Date
    var endDate: Date
    var days: [Day]
}

struct Day: Identifiable {
    let id = UUID()
    var date: Date
    var activities: [Activity]
    var accommodations: [Accommodation]
    var transportation: [Transportation]
}

struct Activity: Identifiable {
    let id = UUID()
    var name: String
    var time: Date
}

struct Accommodation: Identifiable {
    let id = UUID()
    var name: String
    var location: String
}

struct Transportation: Identifiable {
    let id = UUID()
    var type: String
    var details: String
}
