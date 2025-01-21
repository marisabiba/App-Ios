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
    @State private var selectedCategory: ActivityCategory = .other
    
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
                
                Section(header: Text("Category")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ActivityCategory.allCases, id: \.self) { category in
                                VStack {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedCategory == category ? .white : category.color)
                                        .frame(width: 50, height: 50)
                                        .background(selectedCategory == category ? category.color : Color.gray.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .foregroundColor(selectedCategory == category ? category.color : .primary)
                                }
                                .onTapGesture {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let activity = Activity(
                            time: time,
                            title: title,
                            location: location,
                            notes: notes,
                            category: selectedCategory
                        )
                        viewModel.addActivity(to: trip, dayIndex: dayIndex, activity: activity)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .tint(.blue)
                    .bold()
                }
            }
        }
    }
} 
