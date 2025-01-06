import SwiftUI

struct MainView: View {
    @StateObject private var tripViewModel = TripViewModel() // Use ViewModel for managing trips
    @State private var showAddTripSheet = false // Track the sheet visibility

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(tripViewModel.trips) { trip in
                        NavigationLink(destination: TripDetailsView(viewModel: tripViewModel, trip: trip)) {
                            TripCardView(trip: trip)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(16)
            }
            .navigationTitle("Trips")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddTripButton {
                        showAddTripSheet.toggle() // Show the Add Trip view
                    }
                }
            }
            .sheet(isPresented: $showAddTripSheet) {
                AddTripView(viewModel: tripViewModel) // Pass the ViewModel to AddTripView
            }
        }
    }
}

// Preview Struct
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
