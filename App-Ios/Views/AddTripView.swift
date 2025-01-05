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
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        createTrip()
                        dismiss()
                    }
                    .disabled(tripName.isEmpty || endDate < startDate)
                    .bold()
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
