import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripViewModel
    
    @State private var tripName = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400) // Next day
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Trip Name", text: $tripName)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }
            .navigationTitle("New Trip")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let newTrip = Trip(name: tripName,
                                     startDate: startDate,
                                     endDate: endDate)
                    viewModel.addTrip(trip: newTrip)
                    dismiss()
                }
                .disabled(tripName.isEmpty)
            )
        }
    }
}

struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
        AddTripView(viewModel: TripViewModel())
    }
}
