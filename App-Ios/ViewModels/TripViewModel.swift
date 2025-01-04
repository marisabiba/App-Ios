import SwiftUI

final class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = [] // Array of trips

    func addTrip(trip: Trip) {
        trips.append(trip) // Append to the list
        saveTrips() // Persist changes
    }

    private func saveTrips() {
        // TODO: Implement Core Data or UserDefaults saving logic
    }
}
