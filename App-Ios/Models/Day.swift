import Foundation

struct Day: Identifiable {
    var id = UUID()
    var date: Date
    var activities: [Activity]
    var accommodations: [Accommodation]
    var transportation: [Transportation]
}
