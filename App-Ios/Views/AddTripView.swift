import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripViewModel
    
    @State private var tripName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showTripDetails = false
    @State private var newTrip: Trip?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    TextField("Trip Name", text: $tripName)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section {
                    Button("Create Trip and Add Itinerary Now") {
                        createTrip()
                        showTripDetails = true
                    }
                    .disabled(tripName.isEmpty)
                    
                    Button("Create Trip and Add Itinerary Later") {
                        createTrip()
                        dismiss()
                    }
                    .disabled(tripName.isEmpty)
                }
            }
            .navigationTitle("New Trip")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showTripDetails) {
                if let trip = newTrip {
                    TripDetailsView(viewModel: viewModel, trip: trip)
                }
            }
        }
    }
    
    private func createTrip() {
        let trip = Trip(
            name: tripName,
            startDate: startDate,
            endDate: endDate,
            days: [] // Empty array of days initially
        )
        viewModel.addTrip(trip)
        newTrip = trip
    }
}

struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
        AddTripView(viewModel: TripViewModel())
    }
}
