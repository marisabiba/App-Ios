import SwiftUI

struct ItineraryView: View {
    @StateObject private var tripViewModel = TripViewModel() // Bind to ViewModel
    @State private var showAddTripSheet = false // Track sheet visibility

    var body: some View {
        NavigationView {
            VStack {
                if tripViewModel.trips.isEmpty {
                    Text("No trips available. Tap 'Add Trip' to create one.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(tripViewModel.trips) { trip in
                            TripCardView(trip: trip) // Custom card view
                        }
                    }
                }
                Spacer()
                Button(action: {
                    showAddTripSheet.toggle()
                }) {
                    Text("Add Trip")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                .sheet(isPresented: $showAddTripSheet) {
                    AddTripView(viewModel: tripViewModel) // Pass ViewModel to the sheet
                }
            }
            .navigationTitle("Itinerary")
        }
    }
}

struct ItineraryView_Previews: PreviewProvider {
    static var previews: some View {
        ItineraryView()
    }
}
