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

    func addTrip(trip: Trip) {
        trips.append(trip)
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
            trips[index] = Trip(id: id, name: name, startDate: startDate, endDate: endDate)
        }
    }

    func deleteTrip(id: UUID) {
        trips.removeAll { $0.id == id }
    }
}
