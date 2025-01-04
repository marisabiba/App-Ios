import SwiftUI

struct AddTripView: View {
    @ObservedObject var viewModel: TripViewModel // Pass ViewModel from parent
    @Environment(\.presentationMode) var presentationMode

    @State private var tripName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    TextField("Trip Name", text: $tripName)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Trip")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTrip = Trip(name: tripName, startDate: startDate, endDate: endDate)
                        viewModel.addTrip(trip: newTrip)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(tripName.isEmpty) // Disable save if name is empty
                }
            }
        }
    }
}

struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
        AddTripView(viewModel: TripViewModel())
    }
}
