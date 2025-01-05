import Foundation

final class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = [] {
        didSet {
            saveTrips()
        }
    }

    private let tripsKey = "savedTrips"

    init() {
        loadTrips()
    }

    func addTrip(_ trip: Trip) {
        // Initialize empty days for the trip
        var newTrip = trip
        let calendar = Calendar.current
        let numberOfDays = trip.numberOfDays
        
        var days: [TripDay] = []
        for dayIndex in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: dayIndex, to: trip.startDate) {
                let day = TripDay(
                    date: date,
                    title: "",
                    activities: [],
                    transportationDetails: TransportationDetails(mode: "", time: date),
                    budgetDetails: BudgetDetails(amount: 0),
                    checklist: []
                )
                days.append(day)
            }
        }
        
        newTrip.days = days
        trips.append(newTrip)
    }

    func addActivity(to trip: Trip, dayIndex: Int, activity: Activity) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[tripIndex].days[dayIndex].activities.append(activity)
    }

    private func saveTrips() {
        if let data = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(data, forKey: tripsKey)
        }
    }

    private func loadTrips() {
        if let data = UserDefaults.standard.data(forKey: tripsKey),
           let savedTrips = try? JSONDecoder().decode([Trip].self, from: data) {
            trips = savedTrips
        }
    }

    func updateTrip(id: UUID, name: String, startDate: Date, endDate: Date) {
        if let index = trips.firstIndex(where: { $0.id == id }) {
            // Create an array of TripDays based on the date range
            let calendar = Calendar.current
            let numberOfDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0 + 1
            
            var days: [TripDay] = []
            for dayOffset in 0..<numberOfDays {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                    let tripDay = TripDay(
                        date: date,
                        title: "Day \(dayOffset + 1)",
                        activities: [],
                        transportationDetails: TransportationDetails(mode: "", time: date),
                        budgetDetails: BudgetDetails(amount: 0),
                        checklist: []
                    )
                    days.append(tripDay)
                }
            }
            
            trips[index] = Trip(
                id: id,
                name: name,
                startDate: startDate,
                endDate: endDate,
                days: days
            )
        }
    }

    func deleteTrip(id: UUID) {
        trips.removeAll { $0.id == id }
    }

    func updateDayTitle(tripId: UUID, dayIndex: Int, newTitle: String) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].days[dayIndex].title = newTitle
        }
    }

    func updateTransportation(tripId: UUID, dayIndex: Int, transportation: TransportationDetails) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].days[dayIndex].transportationDetails = transportation
        }
    }

    func updateBudget(tripId: UUID, dayIndex: Int, budget: BudgetDetails) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].days[dayIndex].budgetDetails = budget
        }
    }
}
