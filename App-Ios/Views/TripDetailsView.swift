import SwiftUI

struct TripDetailsView: View {
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip
    @State private var isEditing = false
    @State private var editedName: String
    @State private var editedStartDate: Date
    @State private var editedEndDate: Date
    
    init(viewModel: TripViewModel, trip: Trip) {
        self.viewModel = viewModel
        self.trip = trip
        _editedName = State(initialValue: trip.name)
        _editedStartDate = State(initialValue: trip.startDate)
        _editedEndDate = State(initialValue: trip.endDate)
    }

    var body: some View {
        Form {
            if isEditing {
                Section("Trip Details") {
                    TextField("Trip Name", text: $editedName)
                    DatePicker("Start Date", selection: $editedStartDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $editedEndDate, displayedComponents: .date)
                }
            } else {
                Section("Trip Details") {
                    Text(trip.name)
                    Text("Start Date: \(formattedDate(trip.startDate))")
                    Text("End Date: \(formattedDate(trip.endDate))")
                }
            }
        }
        .navigationTitle("Trip Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        // Save changes
                        viewModel.updateTrip(id: trip.id, name: editedName, startDate: editedStartDate, endDate: editedEndDate)
                    }
                    isEditing.toggle()
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
