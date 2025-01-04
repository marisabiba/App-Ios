import SwiftUI

struct MainView: View {
    @State private var trips: [Day] = [
        Day(
            date: Date(),
            activities: [Activity(name: "Visit Museum"), Activity(name: "Explore Park")],
            accommodations: [Accommodation(name: "Hotel ABC")],
            transportation: [Transportation(type: "Bus")]
        ),
        Day(
            date: Date().addingTimeInterval(86400), // Next day
            activities: [Activity(name: "Go Hiking")],
            accommodations: [Accommodation(name: "Cabin XYZ")],
            transportation: [Transportation(type: "Car")]
        )
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(trips) { trip in
                    ItineraryCard(day: trip) {
                        print("Tapped on \(trip.date)")
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Trips")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddTripButton {
                        print("Add trip tapped")
                    }
                }
            }
        }
    }
}
