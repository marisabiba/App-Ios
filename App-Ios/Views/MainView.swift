import SwiftUI

struct MainView: View {
    @StateObject private var tripViewModel = TripViewModel()
    @State private var showAddTripSheet = false
    @State private var selectedSection = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Trips")
                        .font(.title)
                        .bold()
                    Spacer()
                    AddTripButton { showAddTripSheet.toggle() }
                }
                .padding()

                // Segmented Control
                Picker("Sections", selection: $selectedSection) {
                    Text("Upcoming").tag(0)
                    Text("Finished").tag(1)
                    Text("All").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                switch selectedSection {
                case 0:
                    upcomingTripsView
                case 1:
                    finishedTripsView
                default:
                    allTripsView
                }
            }
            .sheet(isPresented: $showAddTripSheet) {
                AddTripView(viewModel: tripViewModel)
            }
        }
    }

    private var upcomingTripsView: some View {
        let now = Date()
        let upcomingTrips = tripViewModel.trips
            .filter { $0.endDate >= now }
            .sorted { lhs, rhs in
                let lhsCurrent = lhs.startDate <= now && lhs.endDate >= now
                let rhsCurrent = rhs.startDate <= now && rhs.endDate >= now
                if lhsCurrent && !rhsCurrent { return true }
                if rhsCurrent && !lhsCurrent { return false }
                return lhs.startDate < rhs.startDate
            }

        return ScrollView {
            VStack(spacing: 16) {
            ForEach(upcomingTrips) { trip in
                ZStack(alignment: .topLeading) {
                if trip.startDate <= now && trip.endDate >= now {
                    Text("Current")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding([.top, .leading], 8)
                    .zIndex(1)
                }
                NavigationLink(destination: TripDetailsView(viewModel: tripViewModel, trip: trip)) {
                    TripCardView(trip: trip)
                }
                .buttonStyle(.plain)
                }
            }
            }
            .padding()
        }
    }

    private var finishedTripsView: some View {
        let finishedTrips = tripViewModel.trips.filter { $0.endDate < Date() }
        return ScrollView {
            VStack(spacing: 16) {
                ForEach(finishedTrips) { trip in
                    NavigationLink(destination: TripDetailsView(viewModel: tripViewModel, trip: trip)) {
                        TripCardView(trip: trip)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private var allTripsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(tripViewModel.trips) { trip in
                    NavigationLink(destination: TripDetailsView(viewModel: tripViewModel, trip: trip)) {
                        TripCardView(trip: trip)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}