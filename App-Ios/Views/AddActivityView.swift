import SwiftUI

struct AddActivityView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip
    let dayIndex: Int
    
    @State private var time = Date()
    @State private var title = ""
    @State private var location = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    DatePicker("Time", selection: $time, displayedComponents: [.hourAndMinute])
                    TextField("Activity Title", text: $title)
                    TextField("Location", text: $location)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Button("Add Activity") {
                    let activity = Activity(
                        time: time,
                        title: title,
                        location: location,
                        notes: notes
                    )
                    viewModel.addActivity(to: trip, dayIndex: dayIndex, activity: activity)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
            .navigationTitle("New Activity")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
} 