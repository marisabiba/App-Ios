import SwiftUI

struct EditTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip
    
    @State private var tripName: String
    @State private var startDate: Date
    @State private var endDate: Date
    
    init(viewModel: TripViewModel, trip: Trip) {
        self.viewModel = viewModel
        self.trip = trip
        _tripName = State(initialValue: trip.name)
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    TextField("Trip Name", text: $tripName)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateTrip(
                            id: trip.id,
                            name: tripName,
                            startDate: startDate,
                            endDate: endDate
                        )
                        dismiss()
                    }
                    .disabled(tripName.isEmpty || endDate < startDate)
                }
            }
        }
    }
} 